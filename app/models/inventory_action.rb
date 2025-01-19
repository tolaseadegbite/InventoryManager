class InventoryAction < ApplicationRecord
  belongs_to :item, counter_cache: :inventory_actions_count
  belongs_to :account, counter_cache: :inventory_actions_count
  
  validates :action_type, presence: true, inclusion: { in: %w[add remove] }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  
  scope :ordered, -> { order(created_at: :desc) }
end