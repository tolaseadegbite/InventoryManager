class ActivityLogPolicy < ApplicationPolicy
  def index?
    inventory_user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      # Get the inventory ID from the current scope (if available)
      inventory_id = scope.where.not(inventory_id: nil).pick(:inventory_id)
      
      # If we're filtering by a specific inventory
      if inventory_id
        inventory_user = user.inventory_users.find_by(inventory_id: inventory_id)
        return scope.none unless inventory_user
        
        # For managers, show all logs for this inventory
        if inventory_user.manager?
          return scope.where(inventory_id: inventory_id)
        end
        
        # For item administrators, filter by their category permissions
        if inventory_user.item_administrator?
          permitted_category_ids = inventory_user.permitted_categories.pluck(:id)
          
          return scope.where(inventory_id: inventory_id)
            .left_joins("LEFT JOIN items ON activity_logs.trackable_type = 'Item' AND activity_logs.trackable_id = items.id")
            .where("items.category_id IN (?) OR activity_logs.trackable_type != 'Item'", permitted_category_ids)
            .distinct
        end
        
        # For viewers, only show logs for items in their permitted categories
        permitted_category_ids = inventory_user.permitted_categories.pluck(:id)
        return scope.where(inventory_id: inventory_id)
          .left_joins("LEFT JOIN items ON activity_logs.trackable_type = 'Item' AND activity_logs.trackable_id = items.id")
          .where("items.category_id IN (?)", permitted_category_ids)
          .distinct
      else
        # If no specific inventory, return logs for all inventories the user has access to
        inventory_ids = user.inventory_users.pluck(:inventory_id)
        scope.where(inventory_id: inventory_ids)
      end
    end
  end
end