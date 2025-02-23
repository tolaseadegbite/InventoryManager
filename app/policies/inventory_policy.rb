class InventoryPolicy < ApplicationPolicy
  def show?
    inventory_user.present?
  end

  def create?
    true # Any authenticated user can create an inventory
  end

  def update?
    manager?
  end

  def destroy?
    manager?
  end

  def confirm_delete?
    manager?
  end

  def dashboard?
    show?
  end

  def manage_users?
    manager?
  end

  def manage_invitations?
    manager?
  end

  def manage_categories?
    manager?
  end

  def manage_items?
    return false unless inventory_user
    return true if manager?
    return false if viewer?
    
    # Item administrators can only create items if they have permitted categories
    item_administrator? && inventory_user.permitted_categories.exists?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:inventory_users).where(inventory_users: { user_id: user.id })
    end
  end
end