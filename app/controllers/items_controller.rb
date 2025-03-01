class ItemsController < ApplicationController
  include Pagy::Backend
  before_action :set_inventory
  before_action :set_item, only: [:show, :edit, :update, :destroy, :modify_quantity, :quantity_modal, :confirm_delete]
  before_action -> { authorize @item }, only: [:show, :edit, :update, :confirm_delete, :destroy]
  before_action -> { authorize @inventory, :manage_items? }, only: [:new, :create]
  before_action -> { authorize @item, :modify_quantity? }, only: [:modify_quantity, :quantity_modal]

  def index
    base_query = policy_scope(@inventory.items)
    @q = base_query.ransack(params[:q])
    @pagy, @items = pagy(@q.result.includes(:category).ordered, limit: 30)
  end

  def show
    @q = @item.inventory_actions.ransack(params[:q])
    @inventory_actions = @q.result.includes(:user).ordered
  end

  def new
    @item = @inventory.items.build(category_id: params[:category_id])
  end

  def create
    @item = @inventory.items.build(item_params)
    @item.user = current_user

    manager = Items::ItemManager.new(@item, current_user)
    if manager.create
      respond_to do |format|
        format.html { redirect_to inventory_item_path(@inventory, @item), notice: "Item was successfully created" }
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
    manager = Items::ItemManager.new(@item, current_user)
    if manager.update(item_params)
      respond_to do |format|
        format.html { redirect_to inventory_item_path(@inventory, @item), notice: "Item was successfully updated" }
        format.turbo_stream { flash.now[:notice] = "Item was successfully updated" }
      end
    else
      flash.now[:alert] = "Failed to update item. Please check the errors below."
      render :edit, status: :unprocessable_entity
    end
  end

  def confirm_delete
  end

  def destroy
    manager = Items::ItemManager.new(@item, current_user)
    manager.destroy
    redirect_to inventory_items_path(@inventory), notice: "Item deleted successfully", status: :see_other
  end

  def quantity_modal
    @action = params[:action_type]
    render :quantity_modal, layout: false
  end

  def modify_quantity
    action = params[:action_type]
    quantity = params[:quantity].to_i
    notes = params[:notes]
  
    manager = Items::ItemManager.new(@item, current_user)
    success = manager.modify_quantity(action, quantity, notes)
    @inventory_actions = @item.inventory_actions.includes(:user).ordered if success
    @q = @item.inventory_actions.ransack(params[:q])
  
    respond_to do |format|
      format.html { 
        redirect_to inventory_item_path(@inventory, @item), 
        notice: success ? "Quantity #{action == 'add' ? 'added' : 'removed'} successfully." : "Failed to #{action} quantity." 
      }
      format.turbo_stream { 
        flash.now[:notice] = success ? "Quantity #{action == 'add' ? 'added' : 'removed'} successfully." : "Failed to #{action} quantity." 
      }
    end
  end    

  def search_modal
    @q = @inventory.items.ransack(params[:q])
    render layout: false
  end

  private

  def set_inventory
    @inventory = Inventory.find(params[:inventory_id])
  end

  def set_category
    @category = Category.find(params[:category_id])
  end

  def set_item
    @item = @inventory.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :quantity, :description, :stock_threshold, :category_id)
  end

  def require_admin
    unless current_user.admin?
      redirect_to inventory_items_path(@inventory), alert: "Unauthorized action."
    end
  end

  def authorize_quantity_modification
    return if params[:action_type] == "remove" || current_user.admin?
    redirect_to inventory_item_path(@inventory, @item), alert: "Unauthorized action."
  end

  def check_category_permission
    inventory_user = @inventory.inventory_users.find_by(user: current_user)
    category = @item&.category || Category.find_by(id: params[:item][:category_id])
    
    unless inventory_user&.can_access_category?(category)
      redirect_to inventory_path(@inventory), alert: "You don't have permission to manage items in this category"
    end
  end
end