class ActivityLogsController < ApplicationController
  include Pagy::Backend
  before_action :set_inventory
  
  def index
    @inventory_user = current_user.inventory_users.find_by(inventory: @inventory)
    
    begin
      # Use the service to get logs based on user's role
      activity_logs = ActivityLogs::ActivityLogService.logs_for_user(@inventory, current_user)
      
      # Paginate the results
      @pagy, @activity_logs = pagy(
        activity_logs.includes(:user, :trackable).recent,
        items: 25
      )
    rescue => e
      # Handle errors gracefully
      Rails.logger.error("Error in activity logs index: #{e.message}")
      @pagy, @activity_logs = pagy(ActivityLog.none, items: 25)
      flash.now[:alert] = "There was an error loading the activity logs."
    end
      
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  private
  
  def set_inventory
    @inventory = Inventory.find(params[:inventory_id])
    authorize @inventory, :show?
  end
end