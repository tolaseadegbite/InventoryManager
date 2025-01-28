class ItemsController < ApplicationController
  include Pagy::Backend
  before_action :set_item, only: [ :show, :edit, :update, :destroy, :modify_quantity, :quantity_modal, :confirm_delete ]
  before_action :require_admin, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :authorize_quantity_modification, only: [ :modify_quantity ]

  def index
    # @items = Item.includes(:category, :user).ordered
    @q = Item.ransack(params[:q])
    # @items = @q.result(distinct: true)
    @pagy, @items = pagy(@q.result.includes(:category).ordered, limit: 30)
  end

  def show
    # @inventory_actions = @item.inventory_actions.includes(:user).ordered
    # if current_user.admin?
    #   @inventory_actions = @item.inventory_actions.includes(:user).ordered
    # else
    #   @inventory_actions = @item.inventory_actions.includes(:user).where(user: current_user).ordered
    # end
    @q = @item.inventory_actions.ransack(params[:q])
    @inventory_actions = @q.result.includes(:user).ordered
  end

  def new
    @item = Item.new
  end

  def create
    @item = current_user.items.build(item_params)

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

  def confirm_delete
  end

  def destroy
    @item.destroy
    redirect_to items_url, notice: "Item deleted successfully", status: :see_other
  end

  def quantity_modal
    @action = params[:action_type]
    render :quantity_modal, layout: false
  end

  def modify_quantity
    action = params[:action_type]
    quantity = params[:quantity].to_i
    notes = params[:notes] # Extract notes from parameters
  
    success = @item.modify_quantity(action, quantity, current_user, notes) # Pass notes here
    @inventory_actions = @item.inventory_actions.includes(:user).ordered if success
    @q = @item.inventory_actions.ransack(params[:q])
  
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @item, notice: success ? "Quantity #{action}ed successfully." : "Failed to #{action} quantity." }
    end
  end    

  def search_modal
    @q = Item.ransack(params[:q])
    render layout: false
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :quantity, :description, :stock_threshold, :category_id)
  end

  def require_admin
    unless current_user.admin?
      redirect_to items_path, alert: "Unauthorized action."
    end
  end

  def authorize_admin_action
    unless current_user.admin?
      redirect_to @item, alert: "Unauthorized action."
    end
  end

  def authorize_quantity_modification
    return if params[:action_type] == "remove" || current_user.admin?
    redirect_to @item, alert: "Unauthorized action."
  end
end
