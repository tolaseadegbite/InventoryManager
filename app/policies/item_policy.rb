class ItemPolicy < ApplicationPolicy
  def index?
    inventory_user.present?
  end

  def show?
    inventory_user.present? && can_access_item?
  end

  def create?
    return true if manager?
    item_administrator? && can_access_item?
  end

  def update?
    return true if manager?
    item_administrator? && can_access_item?
  end

  def destroy?
    return true if manager?
    item_administrator? && can_access_item?
  end

  def modify_quantity?
    return true if manager?
    return true if item_administrator? && can_access_item?
    false
  end

  private

  def can_access_item?
    inventory_user&.can_access_category?(record.category)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      inventory = scope.first&.inventory
      inventory_user = user.inventory_users.find_by(inventory: inventory)

      return scope.all if inventory_user&.manager?
  
      scope.joins(:category)
           .joins("INNER JOIN category_permissions ON categories.id = category_permissions.category_id")
           .where(category_permissions: { inventory_user_id: inventory_user&.id })
           .distinct
    end
  end
end