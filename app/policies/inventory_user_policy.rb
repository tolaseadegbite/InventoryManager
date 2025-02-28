class InventoryUserPolicy < ApplicationPolicy
  def index?
    inventory_user.present?
  end

  def show?
    manager? || record.user_id == user.id
  end

  def create?
    manager?
  end

  def update?
    manager?
  end

  def destroy?
    manager? || record.user_id == user.id # Cannot remove themselves (&&,!=)
  end

  def confirm_delete?
    manager? || record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end