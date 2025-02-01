class Profile < ApplicationRecord
  validates :name, presence: true, length: { minimum: 4, maximum: 50 }
  belongs_to :user

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end

  has_one_attached :avatar do |attachable|
    attachable.variant :display, resize_to_limit: [200, 200]
  end

  validates :avatar, content_type: { in: %w[image/jpeg image/png],
                                    message: "must be a valid image format" },
                    size:         { less_than: 1.megabytes,
                                    message:   "should be less than 1MB" }
end
