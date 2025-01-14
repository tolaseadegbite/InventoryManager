class Profile < ApplicationRecord
  validates :name, presence: true, length: { minimum: 4, maximum: 50 }
  belongs_to :account
end
