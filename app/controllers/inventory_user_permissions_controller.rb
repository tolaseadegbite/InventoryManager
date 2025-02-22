class InventoryUserPermissionsController < ApplicationController
  before_action :set_inventory
  before_action :set_inventory_user
  before_action :authorize_permission
  
  def edit
    @categories = @inventory.categories.ordered
  end
  
  def update
    ActiveRecord::Base.transaction do
      @inventory_user.category_permissions.destroy_all
  
      if params[:all_categories] == "1"
        @inventory.categories.find_each do |category|
          @inventory_user.category_permissions.create!(category: category)
        end
      elsif params[:category_ids].present?
        params[:category_ids].reject(&:blank?).each do |category_id|
          @inventory_user.category_permissions.create!(category_id: category_id)
        end
      end
  
      CategoryPermissionsUpdatedNotifier.with(
        inventory_user: @inventory_user,
        inventory: @inventory
      ).deliver_later(@inventory_user.user)
  
      redirect_to inventory_inventory_users_path(@inventory),
                  notice: "Permissions updated successfully"
    end
  rescue ActiveRecord::RecordInvalid
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