module ActivityLogs
  class ActivityLogService
    # This service handles the creation and querying of activity logs
    
    def self.create(user:, inventory:, action_type:, trackable:, details:)
      # Create a new activity log with the provided parameters
      ActivityLog.create!(
        user: user,
        inventory: inventory,
        action_type: action_type,
        trackable: trackable,
        details: details
      )
    end
    
    def self.logs_for_user(inventory, current_user)
      # Find the user's role in this inventory
      inventory_user = current_user.inventory_users.find_by(inventory: inventory)
      return ActivityLog.none unless inventory_user
      
      # Determine which logs the user can see based on their role
      if inventory_user.manager?
        # Managers see everything
        manager_logs(inventory)
      elsif inventory_user.item_administrator?
        # Item admins see logs for their categories, their own actions, and general inventory changes
        item_admin_logs(inventory, current_user, inventory_user)
      else
        # Viewers only see logs for their permitted categories
        viewer_logs(inventory, inventory_user)
      end
    end
    
    private
    
    def self.manager_logs(inventory)
      # Managers can see all logs for the inventory
      ActivityLog.where(inventory: inventory)
    end
    
    def self.item_admin_logs(inventory, current_user, inventory_user)
      # Get the categories this user has permission for
      category_ids = inventory_user.permitted_categories.pluck(:id)
      category_names = inventory_user.permitted_categories.pluck(:name)
      
      if category_ids.empty?
        # If they have no categories, only show their own actions and general inventory changes
        # (excluding category permissions)
        ActivityLog.where(inventory: inventory)
          .where("activity_logs.user_id = ? OR 
                 (activity_logs.trackable_type NOT IN ('Category', 'Item') AND 
                  activity_logs.action_type NOT LIKE 'category_permission%')", 
                 current_user.id)
      else
        # Show:
        # 1. Their own actions
        # 2. General inventory changes (not category or item specific, and not category permissions)
        # 3. Category activities for their permitted categories
        # 4. Item activities for their permitted categories
        # 5. Category permission activities ONLY for their permitted categories
        ActivityLog.where(inventory: inventory)
          .joins("LEFT JOIN items ON activity_logs.trackable_type = 'Item' AND activity_logs.trackable_id = items.id")
          .where("activity_logs.user_id = ? OR 
                 (activity_logs.trackable_type NOT IN ('Category', 'Item') AND 
                  activity_logs.action_type NOT LIKE 'category_permission%') OR
                 (activity_logs.trackable_type = 'Category' AND activity_logs.trackable_id IN (?)) OR
                 (activity_logs.trackable_type = 'Item' AND items.category_id IN (?)) OR
                 (activity_logs.action_type LIKE 'category_permission%' AND 
                  activity_logs.details->>'category_name' IN (?))",
                 current_user.id, category_ids, category_ids, category_names)
      end
    end
    
    def self.viewer_logs(inventory, inventory_user)
      # Get the categories this user has permission for
      category_ids = inventory_user.permitted_categories.pluck(:id)
      
      if category_ids.empty?
        ActivityLog.none # Return empty relation if no categories
      else
        # Viewers can only see logs for items in their permitted categories
        ActivityLog.where(inventory: inventory)
          .joins("LEFT JOIN items ON activity_logs.trackable_type = 'Item' AND activity_logs.trackable_id = items.id")
          .where("activity_logs.trackable_type = 'Item' AND items.category_id IN (?)", category_ids)
      end
    end
  end
end