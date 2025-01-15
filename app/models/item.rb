class Item < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :account
  has_many :inventory_actions, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  
  scope :ordered, -> { order(id: :desc) }
  
  def add_quantity(amount, current_user)
    return false if amount <= 0
    
    transaction do
      increment!(:quantity, amount)
      inventory_actions.create!(
        account: current_user,
        action_type: 'add',
        quantity: amount
      )
    end
    true
  rescue
    false
  end
  
  def remove_quantity(amount, current_user)
    return false if amount <= 0 || amount > quantity
    
    transaction do
      decrement!(:quantity, amount)
      inventory_actions.create!(
        account: current_user,
        action_type: 'remove',
        quantity: amount
      )
    end
    true
  rescue
    false
  end
end