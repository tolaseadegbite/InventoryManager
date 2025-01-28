class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  # validates :password, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  ###################################################################################################
  attr_accessor :current_password  # Add this line to create a virtual attribute

  validate :validate_current_password, on: :update, if: :email_address_changed?

  # Alias email_address to email
  def email
    email_address
  end

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end
  
  enum :status, { unverified: 0, verified: 1, closed: 2 }
  enum :role, { normal: 0, admin: 1 }

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  has_many :categories, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"

  private

  def validate_current_password
    return unless email_address_changed?

    if current_password.blank?
      errors.add(:current_password, "can't be blank")
    elsif !authenticate(current_password)
      errors.add(:current_password, "is incorrect")
    end
  end
end
