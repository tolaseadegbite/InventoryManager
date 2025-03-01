class InventoryUserPermissionsController < ApplicationController
  before_action :set_inventory
  before_action :set_inventory_user
  before_action :authorize_permission
  
  def edit
    @categories = @inventory.categories.ordered
  end
  
  def update
    # Determine new category IDs based on params
    new_category_ids = if params[:all_categories] == "1"
      @inventory.categories.pluck(:id)
    elsif params[:category_ids].present?
      params[:category_ids].reject(&:blank?).map(&:to_i)
    else
      []
    end
    
    # Create a dummy permission for the manager
    dummy_permission = CategoryPermission.new(inventory_user: @inventory_user)
    manager = CategoryPermissions::CategoryPermissionManager.new(dummy_permission, current_user)
    
    if manager.update_permissions(@inventory_user, new_category_ids)
      redirect_to inventory_inventory_users_path(@inventory),
                  notice: "Permissions updated successfully"
    else
      flash.now[:alert] = "There was an error updating permissions"
      @categories = @inventory.categories.ordered
      render :edit, status: :unprocessable_entity
    end
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