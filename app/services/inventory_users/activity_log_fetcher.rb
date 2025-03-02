module InventoryUsers
  class ActivityLogFetcher
    attr_reader :inventory_user, :params
    
    def initialize(inventory_user, params = {})
      @inventory_user = inventory_user
      @params = params
    end
    
    def fetch
      # Base query for user activities
      user_activities = ActivityLog.where(
        inventory: inventory_user.inventory, 
        user_id: inventory_user.user_id
      ).includes(:user, { user: :profile }, :trackable)
      
      # Initialize Ransack search
      q = user_activities.ransack(params[:q])
      
      # Process date parameters
      if params[:q] && params[:q][:created_at_lteq].present?
        date = Date.parse(params[:q][:created_at_lteq])
        q.created_at_lteq = date.end_of_day
      end
      
      # Set default sort to created_at desc if not specified
      q.sorts = 'created_at desc' if q.sorts.empty?
      
      q.result
    end
  end
end