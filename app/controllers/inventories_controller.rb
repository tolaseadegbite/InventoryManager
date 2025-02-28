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
    
    begin
      @activity_logs = if @inventory_user.manager?
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
      
      @activity_logs = @activity_logs.includes(:user, { user: :profile })
                                    .order(created_at: :desc)
                                    .limit(10)
    rescue => e
      Rails.logger.error("Error in dashboard: #{e.message}")
      @activity_logs = []
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
end