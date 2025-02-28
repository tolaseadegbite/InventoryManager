class InventoryUser < ApplicationRecord
  after_create :check_role_permissions
  after_create :assign_categories_if_manager
  after_create :log_user_added
  after_update :log_role_change, if: :saved_change_to_role?
  after_destroy :log_user_removed

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
    update(role: role)
  end

  def assign_categories_if_manager
    return unless manager?
    
    inventory.categories.find_each do |category|
      category_permissions.create!(category: category)
    end
  end

  def log_user_added
    ActivityLog.create!(
      user: Current.user || user,
      inventory: inventory,
      action_type: :user_added,
      trackable: self,
      details: {
        user_name: user.profile.name,
        role: role.titleize,
        added_by: Current.user&.profile&.name || 'System',
        email: user.email_address
      }
    )
  end

  def log_role_change
    ActivityLog.create!(
      user: Current.user,
      inventory: inventory,
      action_type: :role_changed,
      trackable: self,
      details: {
        user_name: user.profile.name,
        email: user.email_address,
        old_role: role_previously_was.titleize,
        new_role: role.titleize,
        changed_by: Current.user.profile.name
      }
    )
  end

  def log_user_removed
    ActivityLog.create!(
      user: Current.user,
      inventory: inventory,
      action_type: :user_removed,
      trackable: self,
      details: {
        user_name: user.profile.name,
        email: user.email_address,
        role: role.titleize,
        removed_by: Current.user.profile.name
      }
    )
  end
end