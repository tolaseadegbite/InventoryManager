class CategoriesController < ApplicationController
  include Pagy::Backend
  before_action :find_category, only: %w[show edit update destroy confirm_delete]
  before_action :require_admin, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    @categories = Category.all.ordered
    # @pagy, @categories = pagy(@categories, limit: 30)
  end

  def show
    @total_items = @category.items_count
    @q = @category.items.ransack(params[:q])
    # @items = @q.result(distinct: true)
    @pagy, @items = pagy(@q.result.includes(:category).ordered, limit: 10)
  end

  def new
    @category = Category.new
  end

  def create
    @category = current_user.categories.build(category_params)

    if @category.save
      respond_to do |format|
        format.html { redirect_to categories_path, notice: "Category created successfully" }
        format.turbo_stream { flash.now[:notice] = "Category created successfully" }
      end
    else
      flash.now[:alert] = "Failed to create category. Please check the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @q = @category.items.ransack(params[:q])
    if @category.update(category_params)
      respond_to do |format|
        format.html { redirect_to @category, notice: "Category updated successfully" }
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
      format.html { redirect_to categories_url, notice: "Category deleted successfully" }
      # format.turbo_stream { flash.now[:notice] = 'Category deleted successfully' }
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :description)
  end

  def find_category
    @category = Category.find(params[:id])
  end

  def require_admin
    unless current_user.admin?
      redirect_to categories_path, alert: "Unauthorized action."
    end
  end
end
