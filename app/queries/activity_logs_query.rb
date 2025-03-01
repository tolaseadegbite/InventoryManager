class ActivityLogsQuery
  def initialize(inventory, user, inventory_user, limit: 5)
    @inventory = inventory
    @user = user
    @inventory_user = inventory_user
    @limit = limit
  end

  def fetch
    activity_logs = if @inventory_user.manager?
      manager_logs
    elsif @inventory_user.item_administrator?
      item_admin_logs
    else
      viewer_logs
    end

    activity_logs.includes(:user, { user: :profile }, :trackable)
                  .order(created_at: :desc)
                  .limit(@limit)
  end

  private

  def manager_logs
    ActivityLog.where(inventory: @inventory)
  end

  def item_admin_logs
    category_ids = @inventory_user.permitted_categories.pluck(:id)
    category_names = @inventory_user.permitted_categories.pluck(:name)
    
    if category_ids.empty?
      ActivityLog.where(inventory: @inventory)
        .where("activity_logs.user_id = ? OR 
                (activity_logs.trackable_type NOT IN ('Category', 'Item') AND 
                activity_logs.action_type NOT LIKE 'category_permission%')", 
                @user.id)
    else
      ActivityLog.where(inventory: @inventory)
        .joins("LEFT JOIN items ON activity_logs.trackable_type = 'Item' AND activity_logs.trackable_id = items.id")
        .where("activity_logs.user_id = ? OR 
                (activity_logs.trackable_type NOT IN ('Category', 'Item') AND 
                activity_logs.action_type NOT LIKE 'category_permission%') OR
                (activity_logs.trackable_type = 'Category' AND activity_logs.trackable_id IN (?)) OR
                (activity_logs.trackable_type = 'Item' AND items.category_id IN (?)) OR
                (activity_logs.action_type LIKE 'category_permission%' AND 
                activity_logs.details->>'category_name' IN (?))",
                @user.id, category_ids, category_ids, category_names)
    end
  end

  def viewer_logs
    category_ids = @inventory_user.permitted_categories.pluck(:id)
    
    if category_ids.empty?
      ActivityLog.none
    else
      ActivityLog.where(inventory: @inventory)
        .joins("LEFT JOIN items ON activity_logs.trackable_type = 'Item' AND activity_logs.trackable_id = items.id")
        .where("activity_logs.trackable_type = 'Item' AND items.category_id IN (?)", category_ids)
    end
  end
end