class SettingsController < ApplicationController
  
  before_action :ensure_profile_exists, only: [:name, :update_profile]
  layout 'settings'

  def index
  end

  def user_information
  end

  def password
  end

  def email
  end

  def name
  end

  def deactivate_user
  end

  def update_profile
    if @profile.update(profile_params)
      flash[:notice] = "Profile updated successfully."
      redirect_to user_information_settings_path
    else
      flash.now[:alert] = @profile.errors.full_messages.join(", ")
      render :name, status: :unprocessable_entity
    end
  end

  def items
    
  end

  private

  def ensure_profile_exists
    @profile = current_user.profile || current_user.create_profile
  end

  def profile_params
    params.require(:profile).permit(:name, :avatar, :country)
  end
end