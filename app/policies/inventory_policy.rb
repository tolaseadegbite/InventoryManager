class InventoryPolicy < ApplicationPolicy
  def show?
    record.members.include?(user) || record.inventory_users.exists?(user_id: user.id)
  end

  def edit?
    record.members.include?(user) || record.inventory_users.exists?(user_id: user.id)
  end

  def update?
    record.members.include?(user) || record.inventory_users.exists?(user_id: user.id)
  end

  def destroy?
    record.members.include?(user) || record.inventory_users.exists?(user_id: user.id)
  end

  def dashboard?
    record.members.include?(user) || record.inventory_users.exists?(user_id: user.id)
  end

  def confirm_delete?
    record.members.include?(user) || record.inventory_users.exists?(user_id: user.id)
  end

  def update_member?
    update?
  end

  def add_member?
    update?
  end

  def remove_member?
    update?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:inventory_users).where(inventory_users: { user_id: user.id })
      end
    end
  end
end