class UsersController < ApplicationController
  include Pagy::Backend
  before_action :find_user, except: :index

  def index
    @q = User.ransack(params[:q])
    @pagy, @users = pagy(@q.result.includes(:profile).ordered, limit: 30)
  end

  def show
    
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.password = SecureRandom.hex(10) # Auto-generate a temp password
    if @user.save
      PasswordsMailer.reset(user).deliver_later # Let them set their own password
      redirect_to users_path, notice: "User created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "User updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: "User successfully deleted!"
  end

  private

  def user_params
    params.expect([:email, :password_digest, :status, :role, :global_stock_threshold])
  end

  def find_user
    @user = User.find(params[:id])
  end
end
