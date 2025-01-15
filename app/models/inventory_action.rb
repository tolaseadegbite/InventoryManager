class InventoryAction < ApplicationRecord
  belongs_to :item
  belongs_to :account
  
  validates :action_type, presence: true, inclusion: { in: %w[add remove] }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  
  scope :ordered, -> { order(created_at: :desc) }
end