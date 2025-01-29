class Item < ApplicationRecord
  after_commit :update_stock_status, if: :should_check_stock?

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_threshold, numericality: { greater_than_or_equal_to: 0 }

  def self.ransackable_attributes(auth_object = nil) 
    ["name", "quantity", "category_id", "low_stock"] 
  end

  def self.ransackable_associations(auth_object = nil)
    ["category"]
  end

  belongs_to :category, counter_cache: :items_count, optional: true
  belongs_to :user, counter_cache: :items_count
  has_many :inventory_actions, dependent: :destroy
  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification"
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"

  scope :ordered, -> { order(id: :desc) }
  scope :low_stock, -> { where(low_stock: true) }

  VALID_ACTIONS = %w[add remove].freeze

  def modify_quantity(action, amount, current_user, notes = nil)
    return false if amount.nil? || amount <= 0
    return false if action == "remove" && amount > quantity
  
    transaction do
      # Store the original quantity for comparison
      original_quantity = quantity
      
      # Update the quantity
      self.quantity = action == "add" ? quantity + amount : quantity - amount
      
      # Force the quantity_changed? flag to be true if the value actually changed
      send(:attribute_will_change!, 'quantity') if quantity != original_quantity
      
      save!
  
      inventory_actions.create!(
        user: current_user,
        action_type: action,
        quantity: amount,
        notes: notes
      )
    end
    true
  rescue => e
    Rails.logger.error "Failed to #{action} quantity: #{e.message}"
    errors.add(:base, e.message)
    false
  end    

  def effective_threshold
    stock_threshold.zero? ? user.global_stock_threshold : stock_threshold
  end

  private

  def should_check_stock?
    saved_change_to_quantity? ||
    saved_change_to_stock_threshold? ||
    (user.saved_change_to_global_stock_threshold? && stock_threshold.zero?) # Only check if item uses global
  end

  def update_stock_status
    return unless quantity.present?

    current_low_stock = quantity <= effective_threshold
    
    if current_low_stock != low_stock
      # Use update instead of update_column to ensure callbacks run
      update(low_stock: current_low_stock)
      notify_admins_of_stock_change if current_low_stock
    end
  end

  def notify_admins_of_stock_change
    LowStockNotifier.with(
      record_id: id,
      record: self,
      quantity: quantity,
      threshold: effective_threshold
    ).deliver_later(User.where(role: :admin))
  end
end