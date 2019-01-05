class UsersController < ApplicationController
  def new
    @user = User.new
    @user.addresses.build
  end

  def edit
    @user = current_user
    @user.password_digest = nil
  end

  def create
    @user = User.create(user_params)
    @user.addresses.first.toggle(:default_address).save
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = 'You are registered and logged in'
      redirect_to profile_path
    else
      render :new
    end
  end

  def update
    @user = User.find(params[:id])
    render file: 'errors/not_found', status: 404 unless current_user == @user || current_admin?

    @user.update(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = 'Profile data updated'
      if current_user == @user
        redirect_to profile_path
      elsif current_admin?
        redirect_to admin_user_path(@user)
      end
    else
      flash[:error] = 'Profile update failed'
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, addresses_attributes: [:nickname, :address, :city, :state, :zip])
  end
end
