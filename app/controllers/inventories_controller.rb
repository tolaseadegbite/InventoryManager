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
    manager = Inventories::InventoryManager.new(@inventory, current_user)

    if manager.create
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
    manager = Inventories::InventoryManager.new(@inventory, current_user)
    
    respond_to do |format|
      if manager.update(inventory_params)
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
    manager = Inventories::InventoryManager.new(@inventory, current_user)
    manager.destroy

    respond_to do |format|
      format.html { redirect_to inventories_path, status: :see_other, notice: "Inventory was successfully destroyed." }
      format.turbo_stream { flash.now[:notice] = "Inventory was successfully deleted" }
    end
  end

  def dashboard
    @inventory_user = current_user.inventory_users.find_by(inventory: @inventory)
    authorize @inventory, :dashboard?
    
    dashboard_service = DashboardService.new(@inventory, current_user)
    dashboard_data = dashboard_service.fetch_data
    
    @activity_logs = dashboard_data[:activity_logs]
    @stats = dashboard_data[:stats]
    @low_stock_items = dashboard_data[:low_stock_items]
    @category_data = dashboard_data[:category_data]
    @inventory_trends = dashboard_data[:inventory_trends]
    @category_overview = dashboard_data[:category_overview]
    @inventory_actions_chart = dashboard_data[:inventory_actions_chart]
    
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
end