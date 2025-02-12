class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email_address, with: ->(e) { e.strip.downcase }




  ###################################################################################################



  attr_accessor :current_password, :admin_action

  validate :validate_current_password, on: :update, if: :should_validate_current_password?

  # Alias email_address to email
  def email
    email_address
  end

  def self.ransackable_attributes(auth_object = nil) 
    ["email_address", "role", "created_at"] 
  end

  def self.ransackable_associations(auth_object = nil)
    ["profile"]
  end
  
  enum :status, { unverified: 0, verified: 1, closed: 2 }

  enum :role, {
    manager: 0,
    item_administrator: 1,
    editor: 2,
    viewer: 3
  }

  validates :role, presence: true

  # Add role permissions concern
  # include HasRolePermissions

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile
  
  has_many :inventories, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"

  scope :ordered, -> { order(id: :desc) }
  
  private

  def should_validate_current_password?
    email_address_changed? && !admin_action
  end

  def validate_current_password
    if current_password.blank?
      errors.add(:current_password, "can't be blank")
    elsif !authenticate(current_password)
      errors.add(:current_password, "is incorrect")
    end
  end
end
