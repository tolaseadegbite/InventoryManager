class ItemsController < ApplicationController
  before_action :authenticate!
  before_action :set_item, only: [:show, :edit, :update, :destroy, :add_quantity, :remove_quantity]
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    @items = Item.includes(:category, :account).ordered
  end

  def show
    # @inventory_actions = @item.inventory_actions.includes(:account).ordered
    if current_account.Admin?
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
      redirect_to @item, notice: 'Item was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: 'Item was successfully updated.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    
  end

  def add_quantity
    authorize_admin_action
    
    if @item.add_quantity(params[:quantity].to_i, current_account)
      redirect_to @item, notice: 'Quantity was successfully added.'
    else
      redirect_to @item, alert: 'Failed to add quantity.'
    end
  end

  def remove_quantity
    if @item.remove_quantity(params[:quantity].to_i, current_account)
      redirect_to @item, notice: 'Quantity was successfully removed.'
    else
      redirect_to @item, alert: 'Failed to remove quantity.'
    end
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :quantity, :description, :category_id)
  end

  def require_admin
    unless current_account.Admin?
      redirect_to items_path, alert: 'Unauthorized action.'
    end
  end

  def authorize_admin_action
    unless current_account.Admin?
      redirect_to @item, alert: 'Unauthorized action.'
    end
  end
end