class Category < ApplicationRecord
  after_create :log_creation
  after_update :log_update
  after_destroy :log_deletion

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

  private

  def log_creation
    ActivityLog.create!(
      user: Current.user,
      inventory: inventory,
      action_type: :category_created,
      trackable: self,
      details: {
        name: name,
        created_by: Current.user.profile.name,
        email: Current.user.email_address,
        description: description
      }
    )
  end

  def log_update
    return unless saved_changes.present?
    
    ActivityLog.create!(
      user: Current.user,
      inventory: inventory,
      action_type: :category_updated,
      trackable: self,
      details: {
        name: name,
        updated_by: Current.user.profile.name,
        email: Current.user.email_address,
        changes: saved_changes.except('updated_at').transform_values { |v| [v[0].to_s, v[1].to_s] }
      }
    )
  end

  def log_deletion
    ActivityLog.create!(
      user: Current.user,
      inventory: inventory,
      action_type: :category_deleted,
      trackable: self,
      details: {
        name: name,
        deleted_by: Current.user.profile.name,
        email: Current.user.email_address,
        items_count: items_count
      }
    )
  end
end
