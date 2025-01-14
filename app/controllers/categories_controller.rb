class CategoriesController < ApplicationController
  before_action :authenticate!
  before_action :find_category, only: %w[show edit update destroy]

  def index
    @categories = @business.categories.ordered
    @pagy, @categories = pagy(@categories, limit: 30)
  end

  def show
    @total_items = @category.items_count
    @items = @category.items.ordered
    @pagy, @items = pagy(@items, limit: 30)
  end

  def new
    @category = Category.new
  end

  def create
    @category = current_account.categories.build(category_params)

    if @category.save
      respond_to do |format|
        format.html { redirect_to business_categories_path(@business), notice: "Category created successfully" }
        format.turbo_stream { flash.now[:notice] = "Category created successfully" }
      end
    else
      flash.now[:alert] = "Failed to create Category. Please check the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      respond_to do |format|
        format.html { redirect_to business_category_path(@business, @category), notice: "Category updated successfully" }
        # format.turbo_stream { flash.now[:notice] = 'category updated successfully' }
      end
    else
      flash.now[:alert] = "Failed to update Category. Please check the errors below."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to business_categories_path(@business), notice: "Category deleted successfully" }
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end

  def find_category
    @category = Category.find(params[:id])
  end
end
