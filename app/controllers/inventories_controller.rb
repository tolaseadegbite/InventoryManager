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

  def dashboard
  end

  private
    def set_inventory
      @inventory = Inventory.find(params.expect(:id))
    end

    def inventory_params
      params.expect(inventory: [ :name, :description, :global_stock_threshold ])
    end

    def authorize_inventory
      authorize @inventory
    end
end