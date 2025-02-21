class InventoryUsersController < ApplicationController
  before_action :set_inventory
  before_action :set_inventory_user, only: [:show, :edit, :update, :destroy, :confirm_delete]

  def index
    @current_tab = params[:tab] || 'users'
    @users = @inventory.inventory_users.includes(:user, user: :profile).order(id: :desc)
    @pending_invitations = @inventory.inventory_invitations.includes(:recipient, recipient: :profile).pending.order(created_at: :desc)
  end

  def show
    @current_tab = params[:tab] || 'activities'
    @permitted_categories = @inventory_user.permitted_categories.ordered
  end

  # def new
  #   @inventory_user = InventoryUser.new
  # end
  
  # def create
  #   authorize @inventory, :add_member?
    
  #   @user = User.find(inventory_user_params[:user_id])
  #   @inventory_user = @inventory.inventory_users.build(inventory_user_params)
    
  #   if @inventory_user.save
  #     redirect_to inventory_inventory_users_path(@inventory), 
  #       notice: "User successfully added to inventory"
  #   else
  #     render :new, status: :unprocessable_entity
  #   end
  # end

  def edit
    authorize @inventory, :update_member?
  end

  def update
    authorize @inventory, :update_member?
    
    if @inventory_user.update(inventory_user_params)
      redirect_to inventory_inventory_users_path(@inventory), notice: "User role updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def confirm_delete  
  end
  
  def destroy
    authorize @inventory, :remove_member?
    @inventory_user.destroy
    redirect_to inventory_inventory_users_path(@inventory), notice: "User removed from inventory"
  end
  
  private
  
  def set_inventory
    @inventory = Inventory.find(params[:inventory_id])
  end

  def set_inventory_user
    @inventory_user = @inventory.inventory_users.find(params[:id])
  end

  def inventory_user_params
    params.require(:inventory_user).permit(:user_id, :role)
  end
end