# app/models/inventory.rb
class Inventory < ApplicationRecord
  after_create :add_creator_as_manager
  after_commit :log_creation, on: :create
  after_commit :log_update, on: :update
  before_destroy :log_deletion
  
  validates :name, presence: true

  belongs_to :user, counter_cache: :inventories_count

  has_many :categories, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :inventory_actions, dependent: :destroy

  has_many :inventory_users, dependent: :destroy
  has_many :members, through: :inventory_users, source: :user

  has_many :inventory_invitations, dependent: :destroy
  has_many :pending_invitations, -> { where(status: :pending) }, class_name: 'InventoryInvitation'

  def add_member(user, role = :viewer)
    inventory_users.create(user: user, role: role)
  end
  
  def remove_member(user)
    inventory_users.find_by(user: user)&.destroy
  end

  scope :ordered, -> { order(id: :asc) }

  scope :owned_by, ->(user) { where(user_id: user.id) }
  scope :associated_with, ->(user) { 
    joins(:inventory_users)
      .where(inventory_users: { user_id: user.id })
      .where.not(user_id: user.id)
      .distinct
  }

  def can_invite?(user)
    return false if user.nil?
    
    # Check if there's any pending invitation
    !inventory_invitations.active.for_recipient(user).exists? &&
      # Check if user is not already a member
      !inventory_users.exists?(user_id: user.id)
  end

  def latest_invitation_for(user)
    inventory_invitations.for_recipient(user).order(created_at: :desc).first
  end

  private

  def add_creator_as_manager
    inventory_users.create!(
      user: user,
      role: :manager
    )
  end

  def log_creation
    ActivityLog.create!(
      user: user,
      inventory: self,
      action_type: :inventory_created,
      trackable: self,
      details: {
        name: name,
        created_by: user.profile.name,
        email: user.email_address,
        global_stock_threshold: global_stock_threshold
      }
    )
  end

  def log_update
    return unless saved_changes.present?
    
    ActivityLog.create!(
      user: Current.user,
      inventory: self,
      action_type: :inventory_updated,
      trackable: self,
      details: {
        name: name,
        updated_by: Current.user.profile.name,
        email: Current.user.email_address,
        changes: saved_changes.except('updated_at').transform_values { |v| [v[0].to_s, v[1].to_s] }
      }
    )
  end

  def log_deletion
    ActivityLog.create!(
      user: Current.user,
      inventory: self,
      action_type: :inventory_deleted,
      trackable: self,
      details: {
        name: name,
        deleted_by: Current.user.profile.name,
        email: Current.user.email_address
      }
    )
  end
end