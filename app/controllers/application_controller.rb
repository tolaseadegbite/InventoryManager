class ApplicationController < ActionController::Base
  before_action :authenticate!, unless: :authentication_page?
  layout :set_layout
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def set_layout
    if rodauth.logged_in?
      if rodauth.current_route.in?([:change_login, :change_password, :close_account])
        "settings"
      else
        "application"
      end
    elsif authentication_page?
      "authentication"
    end
  end  



  #######################################################################################################################
  # rodauth
  #######################################################################################################################

  def authentication_page?
    # Check if the current path matches Rodauth routes
    request.path.start_with?("/auth") || rodauth.current_route.present?
  end

  def current_account
    rodauth.rails_account
  end
  helper_method :current_account # skip if inheriting from ActionController::API

  def authenticate!
    rodauth.require_account # redirect to login page if not authenticated
  end
end
