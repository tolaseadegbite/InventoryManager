class Inventory < ApplicationRecord
  validates :name, presence: true

  belongs_to :user, counter_cache: :inventories_count

  has_many :categories, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :inventory_actions, dependent: :destroy

  scope :ordered, -> { order(id: :asc) }
end
