class ActivityLog < ApplicationRecord
  belongs_to :user
  belongs_to :inventory
  belongs_to :trackable, polymorphic: true
  
  validates :action_type, :details, presence: true
  
  enum :action_type, {
    # Inventory related
    inventory_created: 'inventory_created',
    inventory_updated: 'inventory_updated',
    inventory_deleted: 'inventory_deleted',
    
    # Item related
    item_created: 'item_created',
    item_updated: 'item_updated',
    item_deleted: 'item_deleted',
    quantity_changed: 'quantity_changed',
    
    # Category related
    category_created: 'category_created',
    category_updated: 'category_updated',
    category_deleted: 'category_deleted',
    
    # User management
    user_added: 'user_added',
    user_removed: 'user_removed',
    role_changed: 'role_changed',
    
    # Permissions
    category_permission_granted: 'category_permission_granted',
    category_permission_revoked: 'category_permission_revoked',
    
    # Invitations
    invitation_sent: 'invitation_sent',
    invitation_accepted: 'invitation_accepted',
    invitation_declined: 'invitation_declined',
    invitation_cancelled: 'invitation_cancelled'
  }

  scope :recent, -> { order(created_at: :desc) }
  
  def self.log(user:, inventory:, action_type:, trackable:, details:)
    create!(
      user: user,
      inventory: inventory,
      action_type: action_type,
      trackable: trackable,
      details: details
    )
  end
end