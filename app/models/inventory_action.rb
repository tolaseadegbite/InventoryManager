class InventoryAction < ApplicationRecord
  belongs_to :item, counter_cache: :items_count
  belongs_to :account, counter_cache: :items_count
  
  validates :action_type, presence: true, inclusion: { in: %w[add remove] }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  
  scope :ordered, -> { order(created_at: :desc) }
end