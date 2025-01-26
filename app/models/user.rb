class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  ###################################################################################################

  # Alias email_address to email
  def email
    email_address
  end

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end
  
  enum :status, { unverified: 1, verified: 2, closed: 3 }
  enum :role, { normal: 1, admin: 2 }

  has_one :profile

  has_many :categories, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"
end
