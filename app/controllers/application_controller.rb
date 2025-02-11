class ApplicationController < ActionController::Base
  include Authentication
  layout :set_layout
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user

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
    %w[items categories].include?(controller_name)
  end

  def inventory_show_page?
    controller_name == 'inventories' && action_name == 'show'
  end
  
  def inventory_dashboard_page?
    controller_name == 'inventories' && action_name == 'dashboard'
  end
end
