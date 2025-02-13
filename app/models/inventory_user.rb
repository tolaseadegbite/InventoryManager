class InventoryUser < ApplicationRecord
  belongs_to :inventory
  belongs_to :user
  
  enum :role, {
    admin: 0,
    editor: 1,
    viewer: 2
  }
  
  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :inventory_id }
end
