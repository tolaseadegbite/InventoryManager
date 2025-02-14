class NotificationsController < ApplicationController
  include Pagy::Backend

  before_action :set_notification, only: [:show, :mark_read]

  def index
    @pagy, @notifications = pagy(current_user.notifications.includes(:event).newest_first, limit: 10)
  end

  def show
    @notification.mark_as_read
    redirect_to @notification.url
  end

  def mark_read
    @notification.mark_as_read
  
    if params[:redirect] == 'true'
      redirect_to @notification.url # Dynamically uses the notifier's URL
    else
      redirect_back(fallback_location: notifications_path)
    end
  end

  def mark_all_read
    current_user.notifications.mark_as_read
    redirect_back(fallback_location: notifications_path)
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end