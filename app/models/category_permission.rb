class CategoryPermission < ApplicationRecord
  belongs_to :inventory_user
  belongs_to :category
  
  validates :category_id, uniqueness: { scope: :inventory_user_id }
  validate :category_belongs_to_inventory
  
  private
  
  def category_belongs_to_inventory
    return unless category && inventory_user
    
    unless category.inventory_id == inventory_user.inventory_id
      errors.add(:category, "must belong to the same inventory")
    end
  end
end
