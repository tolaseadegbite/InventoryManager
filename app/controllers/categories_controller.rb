class CategoriesController < ApplicationController
  include Pagy::Backend
  before_action :find_inventory
  before_action :find_category, only: %w[show edit update destroy confirm_delete]
  before_action :set_inventory_user
  before_action -> { authorize @category }, only: [:show, :edit, :update, :destroy, :confirm_delete]
  before_action -> { authorize @inventory, :manage_categories? }, only: [:new, :create]

  def index
    if inventory_user = @inventory.inventory_users.find_by(user: current_user)
      @categories = inventory_user.permitted_categories.ordered
    else
      @categories = @inventory.categories.ordered
    end

    @pagy, @categories = pagy(@categories, limit: 30)
  end

  def show
    @total_items = @category.items_count
    base_query = policy_scope(@category.items)
    @q = base_query.ransack(params[:q])
    @pagy, @items = pagy(@q.result.includes(:category).ordered, limit: 10)
  end

  def new
    @category = @inventory.categories.build
  end

  def create
    @item = @inventory.items.build(item_params)
    @item.user = current_user
    @item.category_id = params[:category_id] if params[:category_id].present?
  
    if @item.save
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
    @q = @category.items.ransack(params[:q])
    if @category.update(category_params)
      respond_to do |format|
        format.html { redirect_to inventory_category_path(@inventory, @category), notice: "Category updated successfully" }
        format.turbo_stream { flash.now[:notice] = "Category updated successfully" }
      end
    else
      flash.now[:alert] = "Failed to update Category. Please check the errors below."
      render :edit, status: :unprocessable_entity
    end
  end

  def confirm_delete
  end

  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to inventory_categories_path(@inventory), notice: "Category deleted successfully" }
      format.turbo_stream { flash.now[:notice] = 'Category deleted successfully' }
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :description)
  end

  def find_inventory
    @inventory = Inventory.find(params[:inventory_id])
  end

  def find_category
    @category = @inventory.categories.find(params[:id])
  end

  def set_inventory_user
    @inventory_user = @inventory.inventory_users.find_by(user: current_user)
  end

  def require_admin
    unless current_user.admin?
      redirect_to inventory_categories_path(@inventory), alert: "Unauthorized action."
    end
  end
end