class ItemPolicy < ApplicationPolicy
  def index?
    inventory_user.present?
  end

  def show?
    return true if manager?
    inventory_user.present? && inventory_user.can_access_category?(record.category)
  end

  def create?
    return true if manager?
    item_administrator? && inventory_user.can_access_category?(record.category)
  end

  def update?
    return true if manager?
    item_administrator? && inventory_user.can_access_category?(record.category)
  end

  def destroy?
    return true if manager?
    item_administrator? && inventory_user.can_access_category?(record.category)
  end

  def modify_quantity?
    return true if manager?
    return true if item_administrator? && inventory_user.can_access_category?(record.category)
    return record.action_type == 'remove' if inventory_user.present?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.manager?
      
      if user.item_administrator?
        scope.joins(:category)
             .joins("LEFT JOIN category_permissions ON categories.id = category_permissions.category_id")
             .where("category_permissions.inventory_user_id = ? OR categories.id IS NULL", inventory_user.id)
      else
        scope.joins(:category)
             .joins("LEFT JOIN category_permissions ON categories.id = category_permissions.category_id")
             .where("category_permissions.inventory_user_id = ?", inventory_user.id)
      end
    end
  end
end