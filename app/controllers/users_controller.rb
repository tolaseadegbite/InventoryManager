class UsersController < ApplicationController
  include Pagy::Backend
  before_action :find_user, only: %w[show edit update destroy confirm_delete]
  before_action :require_admin

  def index
    @q = User.ransack(params[:q])
    @pagy, @users = pagy(@q.result.includes(:profile).ordered, limit: 30)
  end

  def show
  end

  def new
    @user = User.new
    @user.build_profile
  end

  def create
    @user = User.new(user_params)
    @user.password = 'Password' # Temporary password
    if @user.save
      PasswordsMailer.reset(@user).deliver_later
      respond_to do |format|
        format.html { redirect_to users_path, notice: "User created!" }
        format.turbo_stream do
          format.turbo_stream { flash.now[:notice] = "User updated!" }
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @user.admin_action = current_user.manager?
    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to @user, notice: "User updated!" }
        format.turbo_stream { flash.now[:notice] = "User updated!" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def confirm_delete
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: "User successfully deleted!"
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :role, profile_attributes: [ :id, :name ])
  end

  def find_user
    @user = User.find(params[:id,])
  end

  def require_admin
    unless current_user.manager?
      redirect_to items_path, alert: "Unauthorized action."
    end
  end
end
