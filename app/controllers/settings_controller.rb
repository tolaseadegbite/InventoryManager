class SettingsController < ApplicationController
  before_action :ensure_profile_exists, only: [:name, :update_profile]
  layout 'settings'

  def index
  end

  def user_information
  end

  def password
    render 'passwords/edit'
  end

  def update_password
    
  end

  def update_email
    if current_user.update(email_params)
      redirect_to account_information_settings_path, notice: "Email updated successfully!"
    else
      flash.now[:alert] = current_user.errors.full_messages.join(", ")
      render :email, status: :unprocessable_entity    
    end
  end

  def name
  end

  def deactivate_user
  end

  def update_profile
    if @profile.update(profile_params)
      flash[:notice] = "Profile updated successfully."
      redirect_to account_information_settings_path
    else
      flash.now[:alert] = @profile.errors.full_messages.join(", ")
      render :name, status: :unprocessable_entity
    end
  end

  def items
    
  end

  def global_stock_threshold
    
  end

  def update_global_stock_threshold
    if current_user.update(global_stock_threshold_params)
      flash[:notice] = "Global stock threshold updated successfully."
      redirect_to items_setting_path
    else
      flash.now[:alert] = current.errors.full_messages.join(", ")
      render :global_stock_threshold, status: :unprocessable_entity
    end
  end

  private

  def email_params
    params.require(:user).permit(:email_address, :current_password)
  end
  
  def global_stock_threshold_params
    params.require(:user).permit(:global_stock_threshold)
  end

  def ensure_profile_exists
    @profile = current_user.profile || current_user.create_profile
  end

  def profile_params
    params.require(:profile).permit(:name, :avatar, :country)
  end
end