class Item < ApplicationRecord
  after_save :check_stock_level, if: :should_check_stock?
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_threshold, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :category, counter_cache: :items_count, optional: true
  belongs_to :account, counter_cache: :items_count
  has_many :inventory_actions, dependent: :destroy
  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification", dependent: :destroy
  
  scope :ordered, -> { order(id: :desc) }
  scope :low_stock, -> { 
    joins(:account)
    .where("items.quantity <= items.stock_threshold OR items.quantity <= accounts.global_stock_threshold") 
  }
  
  VALID_ACTIONS = %w[add remove].freeze

  def modify_quantity(action, amount, current_account)
    return false if amount.nil? || amount <= 0
    return false if action == 'remove' && amount > quantity

    transaction do
      self.quantity = action == 'add' ? quantity + amount : quantity - amount
      save!
      
      inventory_actions.create!(
        account: current_account,
        action_type: action,
        quantity: amount
      )
    end
    true
  rescue => e
    Rails.logger.error "Failed to #{action} quantity: #{e.message}"
    errors.add(:base, e.message)
    false
  end

  private

  # Determine if stock level should be checked
  def should_check_stock?
    saved_change_to_quantity? || saved_change_to_stock_threshold?
  end

  # Check stock levels and notify admins if stock is low
  def check_stock_level
    return unless quantity.present?

    # Calculate the effective threshold
    effective_threshold = [stock_threshold, account.global_stock_threshold].max

    # Trigger notification if stock is below or equal to the threshold
    if quantity <= effective_threshold
      notify_admins_of_low_stock(effective_threshold)
    end
  end

  # Notify admins of low stock levels
  def notify_admins_of_low_stock(effective_threshold)
    Account.Admin.find_each do |admin|
      LowStockNotifier.with(
        record_id: id,
        quantity: quantity,
        threshold: effective_threshold,
        account_id: admin.id
      ).deliver_later(admin)
    end
  end
end