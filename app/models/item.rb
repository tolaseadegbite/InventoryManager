class Item < ApplicationRecord
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_threshold, numericality: { greater_than_or_equal_to: 0 }
  validates :inventory_id, presence: true

  # Associations
  belongs_to :inventory, counter_cache: :items_count
  belongs_to :category, counter_cache: :items_count, optional: true
  belongs_to :user, counter_cache: :items_count
  has_many :inventory_actions, dependent: :destroy
  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification"
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"

  # Scopes
  scope :ordered, -> { order(id: :desc) }
  scope :low_stock, -> { where(low_stock: true) }

  # Constants
  VALID_ACTIONS = %w[add remove].freeze

  # Class methods
  def self.ransackable_attributes(auth_object = nil) 
    ["name", "quantity", "category_id", "low_stock", "inventory_id"] 
  end

  def self.ransackable_associations(auth_object = nil)
    ["category", "inventory"]
  end

  # Helper method used by the service
  def effective_threshold
    stock_threshold.zero? ? inventory.global_stock_threshold : stock_threshold
  end
end