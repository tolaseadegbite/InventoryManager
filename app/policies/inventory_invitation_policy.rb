class InventoryInvitationPolicy < ApplicationPolicy
  def create?
    manager?
  end

  def destroy?
    manager?
  end

  def respond?
    record.recipient_id == user.id && record.pending?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end