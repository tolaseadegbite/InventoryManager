class InventoriesController < ApplicationController
  before_action :set_inventory, only: %i[ show edit update destroy dashboard confirm_delete ]

  def index
    @inventories = current_user.inventories.ordered
  end

  def show
    # psideba
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

  def dashboard
    
  end

  private
    def set_inventory
      @inventory = current_user.inventories.find(params.expect(:id))
    end

    def inventory_params
      params.expect(inventory: [ :name, :description, :global_stock_threshold ])
    end
end