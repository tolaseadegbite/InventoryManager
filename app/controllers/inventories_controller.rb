class InventoriesController < ApplicationController
  before_action :set_inventory, only: %i[ show edit update destroy dashboard confirm_delete ]
  before_action :authorize_inventory, only: %i[ show edit update destroy dashboard confirm_delete ]

  def index
    @current_tab = params[:tab] || 'owned'
    
    @inventories = if @current_tab == 'owned'
      policy_scope(Inventory).owned_by(Current.user)
    else
      policy_scope(Inventory).associated_with(Current.user)
    end
  end

  def show
  end

  def new
    @inventory = current_user.inventories.build
  end

  def edit
  end

  def create
    @inventory = current_user.inventories.new(inventory_params)

    if @inventory.save
      respond_to do |format|
        format.html { redirect_to @inventory, notice: "Inventory was successfully created" }
        format.turbo_stream { flash.now[:notice] = "Inventory was successfully created" }
      end
    else
      flash.now[:alert] = "Failed to create inventory. Please check the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @inventory.update(inventory_params)
        format.html { redirect_to @inventory, notice: "Inventory was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Inventory was successfully updated" }
      else
        flash.now[:alert] = "Failed to update inventory. Please check the errors below."
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def confirm_delete
  end

  def destroy
    @inventory.destroy!

    respond_to do |format|
      format.html { redirect_to inventories_path, status: :see_other, notice: "Inventory was successfully destroyed." }
      format.turbo_stream { flash.now[:notice] = "Inventory was successfully deleted" }
    end
  end

  # def dashboard
  #   @activity_logs = begin
  #     logs = policy_scope(ActivityLog).where(inventory: @inventory)
  #     logs = logs.includes(:user, { user: :profile })
  #     logs = logs.order(created_at: :desc).limit(10)
  #     logs.to_a # Convert to array to avoid issues with complex includes
  #   rescue => e
  #     Rails.logger.error("Error loading activity logs: #{e.message}")
  #     []
  #   end
  # end

  def dashboard
    @inventory_user = current_user.inventory_users.find_by(inventory: @inventory)
    
    # Fetch recent activity logs with proper permissions
    @activity_logs = fetch_activity_logs_for_dashboard
    
    # Get permitted category IDs once to avoid repeated queries
    permitted_category_ids = @inventory_user.manager? ? nil : @inventory_user.permitted_categories.pluck(:id)
    
    # Get inventory statistics
    @stats = {
      total_items: get_total_items_count(permitted_category_ids),
      low_stock_items: get_low_stock_items_count(permitted_category_ids),
      categories_count: @inventory_user.manager? ? 
                        @inventory.categories.count : 
                        @inventory_user.permitted_categories.count,
      users_count: @inventory.inventory_users.count
    }
    
    # Get low stock items
    @low_stock_items = fetch_low_stock_items
    
    # Get category distribution data for charts
    @category_data = fetch_category_data
    
    # Get inventory trends data
    @inventory_trends = fetch_inventory_trends
    
    # Get category overview
    @category_overview = fetch_category_overview
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end




  private

  def set_inventory
    @inventory = Inventory.find(params[:id])
  end

  def inventory_params
    params.require(:inventory).permit(:name, :description, :global_stock_threshold)
  end

  def authorize_inventory
    authorize @inventory
  end

  def fetch_activity_logs_for_dashboard
    limit = 5
    
    activity_logs = if @inventory_user.manager?
      # Managers see everything
      ActivityLog.where(inventory: @inventory)
    elsif @inventory_user.item_administrator?
      # Item admins see logs for their categories, their own actions, and general inventory changes
      category_ids = @inventory_user.permitted_categories.pluck(:id)
      category_names = @inventory_user.permitted_categories.pluck(:name)
      
      if category_ids.empty?
        # If they have no categories, only show their own actions and general inventory changes
        ActivityLog.where(inventory: @inventory)
          .where("activity_logs.user_id = ? OR 
                 (activity_logs.trackable_type NOT IN ('Category', 'Item') AND 
                  activity_logs.action_type NOT LIKE 'category_permission%')", 
                 current_user.id)
      else
        # Show the same items as in the activity logs controller
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
    
    # Include necessary associations and limit the results
    activity_logs.includes(:user, { user: :profile }, :trackable)
                 .order(created_at: :desc)
                 .limit(limit)
  end

  def get_total_items_count(permitted_category_ids)
    if @inventory_user.manager?
      @inventory.items.count
    else
      @inventory.items.where(category_id: permitted_category_ids).count
    end
  end
  
  def get_low_stock_items_count(permitted_category_ids)
    if @inventory_user.manager?
      @inventory.items.low_stock.count
    else
      @inventory.items.low_stock.where(category_id: permitted_category_ids).count
    end
  end

  def fetch_low_stock_items
    if @inventory_user.manager?
      @inventory.items.low_stock
                .includes(:category)
                .order(quantity: :asc)
                .limit(6)
    else
      category_ids = @inventory_user.permitted_categories.pluck(:id)
      @inventory.items.low_stock
                .where(category_id: category_ids)
                .includes(:category)
                .order(quantity: :asc)
                .limit(6)
    end
  end

  def fetch_category_data
    if @inventory_user.manager?
      categories = @inventory.categories
    else
      categories = @inventory_user.permitted_categories
    end
    
    categories.map do |category|
      {
        name: category.name,
        count: category.items.count
      }
    end
  end

  def fetch_inventory_trends
    # Get the last 6 months of data
    months = 6.times.map { |i| (Date.today - i.months).beginning_of_month }
    
    if @inventory_user.manager?
      # For managers, get all items
      months.map do |month|
        {
          month: month.strftime("%b"),
          count: @inventory.items.where("created_at <= ?", month.end_of_month).count
        }
      end.reverse
    else
      # For others, get only items from permitted categories
      category_ids = @inventory_user.permitted_categories.pluck(:id)
      months.map do |month|
        {
          month: month.strftime("%b"),
          count: @inventory.items.where("created_at <= ? AND category_id IN (?)", 
                                      month.end_of_month, category_ids).count
        }
      end.reverse
    end
  end

  def fetch_category_overview
    if @inventory_user.manager?
      categories = @inventory.categories.includes(:items)
    else
      categories = @inventory_user.permitted_categories.includes(:items)
    end
    
    categories.map do |category|
      items = category.items
      last_activity = ActivityLog.where(trackable: category)
                               .or(ActivityLog.where(trackable: items))
                               .order(created_at: :desc)
                               .first
  
      # Fetch category permissions through a separate query
      permissions = CategoryPermission.includes(inventory_user: { user: :profile })
                                     .where(category_id: category.id)
      
                                     permitted_users = permissions.map do |permission|
                                      inventory_user = permission.inventory_user
                                      user = inventory_user.user
                                      profile = user.profile
                                      
                                      {
                                        name: profile.name,
                                        inventory_user_id: inventory_user.id,
                                        has_avatar: profile.avatar.attached?,
                                        avatar_url: profile.avatar.attached? ? url_for(profile.avatar) : nil,
                                        role: inventory_user.role
                                      }
                                    end
      
      {
        id: category.id,
        name: category.name,
        total_items: items.count,
        low_stock: items.select(&:low_stock).count,
        permitted_users: permitted_users,
        last_activity_at: last_activity&.created_at
      }
    end
  end
end