class InventoryPolicy < ApplicationPolicy
  def show?
    user.manager? || record.members.include?(user)
  end
  
  def update?
    user.manager? || record.inventory_users.admin.exists?(user_id: user.id)
  end

  def update_member?
    update?  # Use same permissions as update
  end
  
  def add_member?
    update?
  end
  
  def remove_member?
    update?
  end
  
  class Scope < Scope
    def resolve
      if user.manager?
        scope.all
      else
        scope.joins(:inventory_users).where(inventory_users: { user_id: user.id })
      end
    end
  end
end