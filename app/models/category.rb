class Category < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1 }

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end

  belongs_to :user
  has_many :items, dependent: :destroy

  scope :ordered, -> { order(id: :desc) }
end
