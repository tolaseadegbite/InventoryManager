class InventoryUser < ApplicationRecord
  after_create :check_role_permissions
  after_create :assign_categories_if_manager

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :inventory_id }
  
  belongs_to :inventory
  belongs_to :user
  has_many :category_permissions, dependent: :destroy
  has_many :permitted_categories, through: :category_permissions, source: :category
  
  enum :role, {
    manager: 0,
    item_administrator: 1,
    viewer: 3
  }

  def self.ransackable_attributes(auth_object = nil)
    ["role", "user_id", "inventory_id", "created_at"]
  end
  
  def self.ransackable_associations(auth_object = nil)
    ["inventory", "user", "category_permissions", "permitted_categories", "user_profile"]
  end

  # Add this scope for better profile searching
  scope :with_user_and_profile, -> { includes(user: :profile) }
  
  def can_access_category?(category)
    return true if manager?
    permitted_categories.include?(category)
  end

  scope :with_permitted_categories, -> { includes(:permitted_categories) }
  
  def permitted_category_ids
    permitted_categories.pluck(:id)
  end
  
  private
  
  def check_role_permissions
    return if manager?
    
    # New inventory users can't do anything until categories are assigned
    # unless they're managers
    update(role: role)
  end

  def assign_categories_if_manager
    return unless manager?
    
    inventory.categories.find_each do |category|
      category_permissions.create!(category: category)
    end
  end
  
end
