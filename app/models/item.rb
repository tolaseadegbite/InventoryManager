class Item < ApplicationRecord
  belongs_to :category, counter_cache: :items_count, optional: true
  belongs_to :account, counter_cache: :items_count
  has_many :inventory_actions, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  
  scope :ordered, -> { order(id: :desc) }
  
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
end