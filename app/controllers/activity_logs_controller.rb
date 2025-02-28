class ActivityLogsController < ApplicationController
  include Pagy::Backend
  before_action :set_inventory

  
  # def index
  #   @pagy, @activity_logs = pagy(
  #     policy_scope(ActivityLog)
  #       .where(inventory: @inventory)
  #       .includes(:user, :trackable)
  #       .recent,
  #     items: 25
  #   )
      
  #   respond_to do |format|
  #     format.html
  #     format.turbo_stream
  #   end
  # end

  
  def index
    @inventory_user = current_user.inventory_users.find_by(inventory: @inventory)
    
    begin
      activity_logs = if @inventory_user.manager?
        # Managers see everything
        ActivityLog.where(inventory: @inventory)
      elsif @inventory_user.item_administrator?
        # Item admins see logs for their categories, their own actions, and general inventory changes
        category_ids = @inventory_user.permitted_categories.pluck(:id)
        category_names = @inventory_user.permitted_categories.pluck(:name)
        
        if category_ids.empty?
          # If they have no categories, only show their own actions and general inventory changes
          # (excluding category permissions)
          ActivityLog.where(inventory: @inventory)
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
          ActivityLog.where(inventory: @inventory)
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
      else
        # Viewers only see logs for their permitted categories
        category_ids = @inventory_user.permitted_categories.pluck(:id)
        
        if category_ids.empty?
          ActivityLog.none # Return empty relation if no categories
        else
          ActivityLog.where(inventory: @inventory)
            .joins("LEFT JOIN items ON activity_logs.trackable_type = 'Item' AND activity_logs.trackable_id = items.id")
            .where("activity_logs.trackable_type = 'Item' AND items.category_id IN (?)", category_ids)
        end
      end
      
      @pagy, @activity_logs = pagy(
        activity_logs.includes(:user, :trackable).recent,
        items: 25
      )
    rescue => e
      Rails.logger.error("Error in activity logs index: #{e.message}")
      @pagy, @activity_logs = pagy(ActivityLog.none, items: 25)
      flash.now[:alert] = "There was an error loading the activity logs."
    end
      
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  private
  
  def set_inventory
    @inventory = Inventory.find(params[:inventory_id])
    authorize @inventory, :show?
  end
end