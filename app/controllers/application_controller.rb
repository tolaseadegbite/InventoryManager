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
    if current_user
      "application"
    else
      "authentication"
    end
  end  
end
