class InventoryInvitationPolicy < ApplicationPolicy
  def respond?
    record.recipient == user && record.pending?
  end
end