class ApplicationController < ActionController::Base
  # Pundit
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  
  include Authentication
  layout :set_layout
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user
  before_action :set_accordion_inventories
  
  # User
  def current_user
    Current.user
  end

  private

  def set_layout
    if inventory_related_view?
      "application"
    elsif current_user
      "inventory_base"
    else
      "authentication"
    end
  end  

  def inventory_related_view?
    params[:inventory_id].present? || controller_with_inventory_association? || inventory_show_page? || inventory_dashboard_page?
  end

  def controller_with_inventory_association?
    %w[items categories inventory_users].include?(controller_name)
  end

  def inventory_show_page?
    controller_name == 'inventories' && action_name == 'show'
  end
  
  def inventory_dashboard_page?
    controller_name == 'inventories' && action_name == 'dashboard'
  end

  def set_accordion_inventories
    if current_user
      @accordion_inventories = current_user.all_inventories.ordered
    end
  end

  # Pundit

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
