class InventoryAction < ApplicationRecord
  validates :action_type, presence: true, inclusion: { in: %w[add remove] }
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  def self.ransackable_attributes(auth_object = nil) 
    ["created_at", "quantity", "account_id", "action_type"] 
  end

  def self.ransackable_associations(auth_object = nil)
    ["account"]
  end

  belongs_to :item, counter_cache: :inventory_actions_count
  belongs_to :account, counter_cache: :inventory_actions_count
  
  scope :ordered, -> { order(created_at: :desc) }
end