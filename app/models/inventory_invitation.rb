class InventoryInvitation < ApplicationRecord
  belongs_to :inventory
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  
  enum :status, { pending: 0, accepted: 1, declined: 2 }
  enum :role, InventoryUser.roles
  
  # Remove the uniqueness validation to allow multiple invitations
  validate :validate_invitation_status
  
  after_create_commit :notify_recipient
  after_update_commit :process_response, if: :saved_change_to_status?

  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification"
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  
  # Scopes for better invitation management
  scope :active, -> { where(status: :pending) }
  scope :for_recipient, ->(user) { where(recipient: user) }
  scope :latest_for_recipient, ->(user) { 
    for_recipient(user)
      .order(created_at: :desc)
      .select('DISTINCT ON (inventory_id) *')
  }
  
  private
  
  def validate_invitation_status
    return unless recipient_id && inventory_id

    # Check for pending invitations
    pending_invitation = inventory.inventory_invitations
      .active
      .for_recipient(recipient)
      .where.not(id: id)
      .exists?

    if pending_invitation
      errors.add(:recipient, "already has a pending invitation to this inventory")
    end

    # Check if user is currently a member
    if inventory.inventory_users.exists?(user_id: recipient_id)
      errors.add(:recipient, "is already a member of this inventory")
    end
  end
  
  def notify_recipient
    InventoryInvitationNotifier.with(
      record_id: id,
      record: self,
      invitation: self,
      inventory: inventory,
      role: role
    ).deliver_later(recipient)
  end
  
  def process_response
    if accepted?
      inventory.add_member(recipient, role)
      InventoryInvitationAcceptedNotifier.with(
        record_id: id,
        record: self,
        invitation: self,
        inventory: inventory,
        user: recipient,
        role: role
      ).deliver_later(sender)
    elsif declined?
      InventoryInvitationDeclinedNotifier.with(
        record_id: id,
        record: self,
        invitation: self,
        inventory: inventory,
        user: recipient,
        role: role
      ).deliver_later(sender)
    end
  end
end