class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :resume_session, only: %i[new create]

  def new
    @user = User.new
    @user.build_profile
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "You've successfully signed up to Inventorify. Welcome!"
    else
      populate_flash_with_errors(@user)
      render :new, status: :unprocessable_entity
    end
  end

  # def create
  #   @user = User.new(user_params.except(:current_password))
  #   if @user.save
  #     start_new_session_for @user
  #     redirect_to root_path, notice: "Welcome!"
  #   else
  #     populate_flash_with_errors(@user)
  #     render :new
  #   end
  # end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, profile_attributes: [:name])
  end

  def populate_flash_with_errors(user)
    if password_confirmation_matches? && user.errors.any?
      flash[:alert] = user.errors.full_messages.join(", ")
    elsif !password_confirmation_matches?
      flash[:alert] = "Password and password confirmation don't match"
    end
  end

  def password_confirmation_matches?
    user_params[:password] == user_params[:password_confirmation]
  end
end
