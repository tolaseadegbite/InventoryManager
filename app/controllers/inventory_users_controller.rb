class InventoryUsersController < ApplicationController
  include Pagy::Backend
  before_action :set_inventory
  before_action :set_inventory_user, only: [:show, :edit, :update, :destroy, :confirm_delete]
  before_action :authorize_inventory_user, except: [:index]

  def index
    authorize @inventory, policy_class: InventoryUserPolicy
    @current_tab = params[:tab] || 'users'
    
    base_query = @inventory.inventory_users.with_user_and_profile
    @q = base_query.ransack(params[:q])
    
    # Add proper sorting for profile name
    @q.sorts = ['user_profile_name asc'] if @q.sorts.empty?
    
    @pagy, @users = pagy(@q.result, items: 30)
    
    @pending_invitations = @inventory.inventory_invitations.includes(:recipient, recipient: :profile).pending.order(created_at: :desc)
  end

  def show
    @current_tab = params[:tab] || 'activities'
    @permitted_categories = @inventory_user.permitted_categories.ordered
    
    if @current_tab == 'activities'
      @pagy, @user_activities = pagy(
        ActivityLog.where(inventory: @inventory, user_id: @inventory_user.user_id)
                  .includes(:user, { user: :profile }, :trackable)
                  .order(created_at: :desc),
        items: 10
      )
    end
  end

  def edit
  end

  def update
    manager = InventoryUsers::InventoryUserManager.new(@inventory_user, current_user)
    
    if manager.update(inventory_user_params)
      redirect_to inventory_inventory_users_path(@inventory), 
                  notice: "User role updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def confirm_delete
  end

  def destroy
    manager = InventoryUsers::InventoryUserManager.new(@inventory_user, current_user)
    
    if manager.destroy
      redirect_to inventory_inventory_users_path(@inventory), 
                  notice: "User removed from inventory"
    else
      redirect_to inventory_inventory_user_path(@inventory, @inventory_user),
                  alert: "Failed to remove user from inventory"
    end
  end

  private

  def set_inventory
    @inventory = Inventory.find(params[:inventory_id])
  end

  def set_inventory_user
    @inventory_user = @inventory.inventory_users.find(params[:id])
  end

  def authorize_inventory_user
    authorize @inventory_user
  end

  def inventory_user_params
    params.require(:inventory_user).permit(:user_id, :role)
  end
end