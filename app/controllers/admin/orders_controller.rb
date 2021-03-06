class Admin::OrdersController < Admin::BaseController
  def index
    @user = User.find(params[:user_id])
    @orders = @user.orders
    render '/profile/orders/index'
  end

  def show
    @user = User.find(params[:user_id])
    @order = Order.find(params[:id])
    render '/profile/orders/show'
  end
end