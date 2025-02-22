class CategoryPolicy < ApplicationPolicy
  def index?
    inventory_user.present?
  end

  def show?
    inventory_user.present? && inventory_user.can_access_category?(record)
  end

  def create?
    manager?
  end

  def update?
    manager?
  end

  def destroy?
    manager?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.manager?
        scope.all
      else
        scope.joins(:category_permissions)
             .where(category_permissions: { inventory_user_id: inventory_user.id })
      end
    end
  end
end