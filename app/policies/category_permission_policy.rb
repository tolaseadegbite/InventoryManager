class CategoryPermissionPolicy < ApplicationPolicy
  def edit?
    manager?
  end

  def update?
    manager?
  end

  private

  def manager?
    user.inventory_users.exists?(inventory_id: record.inventory_user.inventory_id, role: :manager)
  end
end