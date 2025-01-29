class NotificationsController < ApplicationController
  
  before_action :set_notification, only: [:show, :mark_read]

  def index
    @notifications = current_user.notifications.newest_first
    # current_user.notifications.unread.mark_as_read
  end

  def show
    @notification.mark_as_read
    redirect_to @notification.url
  end

  def mark_read
    @notification.mark_as_read
    
    if params[:redirect] == 'true'
      # Get the URL from the event and redirect (for dropdown clicks)
      event = Noticed::Event.find(@notification.event_id)
      redirect_to item_path(event.params[:record_id])
    else
      # Just mark as read and stay on page (for mark as read button)
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