class InventoryUserActivityLogsController < ApplicationController
  before_action :set_inventory_user
  
  # def index
  #   @pagy, @activity_logs = pagy(
  #     policy_scope(ActivityLog)
  #       .where(inventory: @inventory_user.inventory)
  #       .where(user: @inventory_user.user)
  #       .includes(:user, :trackable)
  #       .recent,
  #     items: 25
  #   )
      
  #   respond_to do |format|
  #     format.html
  #     format.turbo_stream
  #   end
  # end

  def index
    @pagy, @activity_logs = pagy(
      ActivityLog
        .where(inventory: @inventory_user.inventory)
        .where(user: @inventory_user.user)
        .includes(:user, :trackable)
        .recent,
      items: 25
    )
      
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  private
  
  def set_inventory_user
    @inventory_user = InventoryUser.find(params[:inventory_user_id])
    authorize @inventory_user.inventory, :show?
  end
end