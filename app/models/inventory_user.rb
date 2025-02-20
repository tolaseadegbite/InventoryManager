class InventoryUser < ApplicationRecord
  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :inventory_id }
  
  belongs_to :inventory
  belongs_to :user
  has_many :category_permissions, dependent: :destroy
  has_many :permitted_categories, through: :category_permissions, source: :category
  
  # enum :role, {
  #   admin: 0,
  #   editor: 1,
  #   viewer: 2
  # }

  enum :role, {
    manager: 0,
    item_administrator: 1,
    viewer: 3
  }

  after_create :check_role_permissions
  
  def can_access_category?(category)
    return true if manager?
    permitted_categories.include?(category)
  end
  
  private
  
  def check_role_permissions
    return if manager?
    
    # New inventory users can't do anything until categories are assigned
    # unless they're managers
    update(role: role)
  end
  
end
