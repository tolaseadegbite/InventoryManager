class Item < ApplicationRecord
  # Callbacks
  after_commit :update_stock_status, if: :should_check_stock?
  after_create :log_creation
  after_update :log_update
  after_destroy :log_deletion

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_threshold, numericality: { greater_than_or_equal_to: 0 }
  validates :inventory_id, presence: true

  # Associations
  belongs_to :inventory, counter_cache: :items_count
  belongs_to :category, counter_cache: :items_count, optional: true
  belongs_to :user, counter_cache: :items_count
  has_many :inventory_actions, dependent: :destroy
  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification"
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"

  # Scopes
  scope :ordered, -> { order(id: :desc) }
  scope :low_stock, -> { where(low_stock: true) }

  # Constants
  VALID_ACTIONS = %w[add remove].freeze

  # Class methods
  def self.ransackable_attributes(auth_object = nil) 
    ["name", "quantity", "category_id", "low_stock", "inventory_id"] 
  end

  def self.ransackable_associations(auth_object = nil)
    ["category", "inventory"]
  end

  # Instance methods
  def modify_quantity(action, amount, current_user, notes = nil)
    return false if amount.nil? || amount <= 0
    return false if action == "remove" && amount > quantity
  
    transaction do
      original_quantity = quantity
      new_quantity = action == "add" ? quantity + amount : quantity - amount
      self.quantity = new_quantity
      send(:attribute_will_change!, 'quantity') if quantity != original_quantity
      save!
  
      inventory_actions.create!(
        inventory: inventory,
        user: current_user,
        action_type: action,
        quantity: amount,
        notes: notes
      )

      # Log the quantity change
      ActivityLog.create!(
        user: current_user,
        inventory: inventory,
        action_type: :quantity_changed,
        trackable: self,
        details: {
          from: original_quantity,
          to: new_quantity,
          action: action,
          notes: notes
        }
      )
    end
    true
  rescue => e
    Rails.logger.error "Failed to #{action} quantity: #{e.message}"
    errors.add(:base, e.message)
    false
  end    

  def effective_threshold
    stock_threshold.zero? ? inventory.global_stock_threshold : stock_threshold
  end

  private

  def should_check_stock?
    saved_change_to_quantity? ||
    saved_change_to_stock_threshold? ||
    (inventory.saved_change_to_global_stock_threshold? && stock_threshold.zero?)
  end

  def update_stock_status
    return unless quantity.present?
  
    current_low_stock = quantity <= effective_threshold
    
    if current_low_stock != low_stock
      update(low_stock: current_low_stock)
      
      if current_low_stock
        notify_admins_of_stock_change
      else
        notify_admins_of_stock_replenishment
      end
    end
  end

  def notify_admins_of_stock_change
    LowStockNotifier.with(
      record_id: id,
      record: self,
      quantity: quantity,
      threshold: effective_threshold,
      inventory_id: inventory_id,
      inventory_name: inventory.name
    ).deliver_later(User.where(role: :admin))
  end

  def notify_admins_of_stock_replenishment
    StockReplenishmentNotifier.with(
      record_id: id,
      record: self,
      quantity: quantity,
      threshold: effective_threshold,
      inventory_id: inventory_id,
      inventory_name: inventory.name
    ).deliver_later(User.where(role: :admin))
  end

  def log_creation
    ActivityLog.create!(
      user: user,
      inventory: inventory,
      action_type: :item_created,
      trackable: self,
      details: {
        name: name,
        category: category&.name,
        quantity: quantity
      }
    )
  end

  def log_update
    return unless saved_changes.present?
    
    ActivityLog.create!(
      user: Current.user,
      inventory: inventory,
      action_type: :item_updated,
      trackable: self,
      details: {
        changes: saved_changes.except('updated_at'),
        name: name
      }
    )
  end

  def log_deletion
    ActivityLog.create!(
      user: Current.user,
      inventory: inventory,
      action_type: :item_deleted,
      trackable: self,
      details: {
        name: name,
        category: category&.name
      }
    )
  end
end