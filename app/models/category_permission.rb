class CategoryPermission < ApplicationRecord
  belongs_to :inventory_user
  belongs_to :category
  
  validates :category_id, uniqueness: { scope: :inventory_user_id }
  validate :category_belongs_to_inventory
  
  after_create :log_permission_granted
  after_destroy :log_permission_revoked
  
  private
  
  def category_belongs_to_inventory
    return unless category && inventory_user
    
    unless category.inventory_id == inventory_user.inventory_id
      errors.add(:category, "must belong to the same inventory")
    end
  end
  
  def log_permission_granted
    ActivityLog.create!(
      user: Current.user,
      inventory: inventory_user.inventory,
      action_type: :category_permission_granted,
      trackable: self,
      details: {
        user_name: inventory_user.user.profile.name,
        category_name: category.name,
        role: inventory_user.role.titleize
      }
    )
  end
  
  def log_permission_revoked
    ActivityLog.create!(
      user: Current.user,
      inventory: inventory_user.inventory,
      action_type: :category_permission_revoked,
      trackable: self,
      details: {
        user_name: inventory_user.user.profile.name,
        category_name: category.name
      }
    )
  end
end