class Category < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1 }

  def self.ransackable_attributes(auth_object = nil)
    ["name", "inventory_id"]
  end
  
  def self.ransackable_associations(auth_object = nil)
    ["inventory", "items"]
  end

  belongs_to :inventory, counter_cache: :categories_count
  has_many :items, dependent: :destroy

  scope :ordered, -> { order(id: :desc) }
end
