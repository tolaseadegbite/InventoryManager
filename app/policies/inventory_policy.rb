class InventoryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end

  def show?
    record.user_id == user.id
  end

  def create?
    user.can_manage_inventory?
  end

  def update?
    show? && user.can_manage_inventory?
  end

  def destroy?
    show? && user.manager?
  end

  def dashboard?
    show?
  end

  def confirm_delete?
    destroy?
  end
end