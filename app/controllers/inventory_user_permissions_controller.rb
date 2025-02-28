class InventoryUserPermissionsController < ApplicationController
  before_action :set_inventory
  before_action :set_inventory_user
  before_action :authorize_permission
  
  def edit
    @categories = @inventory.categories.ordered
  end
  
  def update
    ActiveRecord::Base.transaction do
      # Get current category permissions
      current_category_ids = @inventory_user.category_permissions.pluck(:category_id)
      
      # Determine new category IDs based on params
      new_category_ids = if params[:all_categories] == "1"
        @inventory.categories.pluck(:id)
      elsif params[:category_ids].present?
        params[:category_ids].reject(&:blank?).map(&:to_i)
      else
        []
      end
      
      # Find categories to remove and add
      categories_to_remove = current_category_ids - new_category_ids
      categories_to_add = new_category_ids - current_category_ids
      
      # Remove permissions no longer needed
      if categories_to_remove.any?
        @inventory_user.category_permissions.where(category_id: categories_to_remove).destroy_all
      end
      
      # Add new permissions
      categories_to_add.each do |category_id|
        @inventory_user.category_permissions.create!(category_id: category_id)
      end
  
      # Send notification if changes were made
      if categories_to_remove.any? || categories_to_add.any?
        CategoryPermissionsUpdatedNotifier.with(
          inventory_user: @inventory_user,
          inventory: @inventory
        ).deliver_later(@inventory_user.user)
      end
  
      redirect_to inventory_inventory_users_path(@inventory),
                  notice: "Permissions updated successfully"
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Permission update failed: #{e.message}")
    flash.now[:alert] = "There was an error updating permissions"
    render :edit, status: :unprocessable_entity
  end
  
  private
  
  def set_inventory
    @inventory = Inventory.find(params[:inventory_id])
  end
  
  def set_inventory_user
    @inventory_user = @inventory.inventory_users.find(params[:inventory_user_id])
  end

  def authorize_permission
    # Create a dummy CategoryPermission instance for authorization
    permission = CategoryPermission.new(inventory_user: @inventory_user)
    authorize permission
  end
end