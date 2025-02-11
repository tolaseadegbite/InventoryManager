class InventoriesController < ApplicationController
  before_action :set_inventory, only: %i[ show edit update destroy dashboard confirm_delete ]

  # GET /inventories or /inventories.json
  def index
    @inventories = current_user.inventories.ordered
  end

  # GET /inventories/1 or /inventories/1.json
  def show
  end

  # GET /inventories/new
  def new
    @inventory = current_user.inventories.build
  end

  # GET /inventories/1/edit
  def edit
  end

  # POST /inventories or /inventories.json
  def create
    @inventory = current_user.inventories.new(inventory_params)

    respond_to do |format|
      if @inventory.save
        format.html { redirect_to @inventory, notice: "Inventory was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Inventory was successfully created" }
      else
        flash.now[:alert] = "Failed to create inventory. Please check the errors below."
        render :new, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /inventories/1 or /inventories/1.json
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

  # DELETE /inventories/1 or /inventories/1.json
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
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory
      @inventory = current_user.inventories.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def inventory_params
      params.expect(inventory: [ :name, :description, :global_stock_threshold ])
    end
end