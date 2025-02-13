class Inventory < ApplicationRecord
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
end
