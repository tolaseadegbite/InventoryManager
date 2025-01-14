class Category < ApplicationRecord
  validates :name, presence: true
  belongs_to :account
  # has_many items, dependent: :destroy
  scope :ordered, -> { order(id: :desc) }
end
