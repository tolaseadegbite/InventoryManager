class ItemsController < ApplicationController
  before_action :authenticate!
  before_action :set_item, only: [ :show, :edit, :update, :destroy, :modify_quantity, :quantity_modal ]
  before_action :require_admin, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :authorize_quantity_modification, only: [ :modify_quantity ]

  def index
    @items = Item.includes(:category, :account).ordered
  end

  def show
    # @inventory_actions = @item.inventory_actions.includes(:account).ordered
    if current_account.admin?
      @inventory_actions = @item.inventory_actions.includes(:account).ordered
    else
      @inventory_actions = @item.inventory_actions.includes(:account).where(account: current_account).ordered
    end
  end

  def new
    @item = Item.new
  end

  def create
    @item = current_account.items.build(item_params)

    if @item.save
      respond_to do |format|
        format.html { redirect_to @item, notice: "Item was successfully created" }
        format.turbo_stream { flash.now[:notice] = "Item was successfully created" }
      end
    else
      flash.now[:alert] = "Failed to create item. Please check the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      respond_to do |format|
        format.html { redirect_to @item, notice: "Item was successfully updated" }
        format.turbo_stream { flash.now[:notice] = "Item was successfully updated" }
      end
    else
      flash.now[:alert] = "Failed to update item. Please check the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: "Item deleted successfully" }
      # format.turbo_stream { flash.now[:notice] = 'Item deleted successfully' }
    end
  end

  def quantity_modal
    @action = params[:action_type]
    render :quantity_modal, layout: false
  end

  def modify_quantity
    action = params[:action_type]
    quantity = params[:quantity].to_i
    notes = params[:notes] # Extract notes from parameters
  
    success = @item.modify_quantity(action, quantity, current_account, notes) # Pass notes here
    @inventory_actions = @item.inventory_actions.includes(:account).ordered if success
  
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @item, notice: success ? "Quantity #{action}ed successfully." : "Failed to #{action} quantity." }
    end
  end    

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :quantity, :description, :stock_threshold, :category_id)
  end

  def require_admin
    unless current_account.admin?
      redirect_to items_path, alert: "Unauthorized action."
    end
  end

  def authorize_admin_action
    unless current_account.admin?
      redirect_to @item, alert: "Unauthorized action."
    end
  end

  def authorize_quantity_modification
    return if params[:action_type] == "remove" || current_account.admin?
    redirect_to @item, alert: "Unauthorized action."
  end
end
