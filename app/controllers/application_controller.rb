class ApplicationController < ActionController::Base
  # Pundit
  # include Pundit::Authorization
  # after_action :verify_authorized, except: :index, unless: :devise_controller?
  # after_action :verify_policy_scoped, only: :index, unless: :devise_controller?
  
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  
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

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

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
    %w[items categories].include?(controller_name)
  end

  def inventory_show_page?
    controller_name == 'inventories' && action_name == 'show'
  end
  
  def inventory_dashboard_page?
    controller_name == 'inventories' && action_name == 'dashboard'
  end

  def set_accordion_inventories
    @accordion_inventories = current_user.inventories.ordered
  end
end
