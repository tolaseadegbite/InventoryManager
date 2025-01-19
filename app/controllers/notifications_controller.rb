class NotificationsController < ApplicationController
  before_action :authenticate!
  before_action :set_notification, only: [:mark_read]

  def index
    @notifications = current_account.notifications.newest_first
  end

  def mark_read
    @notification.mark_as_read
    redirect_back(fallback_location: notifications_path)
  end

  def mark_all_read
    current_account.notifications.mark_as_read
    redirect_back(fallback_location: notifications_path)
  end

  private

  def set_notification
    @notification = current_account.notifications.find(params[:id])
  end
end