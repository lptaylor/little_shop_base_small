class Admin::ItemsController < Admin::BaseController
  def index
    @merchant = User.find(params[:merchant_id])
    @items = @merchant.items
    render '/dashboard/items/index'
  end

  def new
    @merchant = User.find(params[:merchant_id])
    @item = Item.new
    @form_path = [:admin, @merchant, @item]
    render "/dashboard/items/new"
  end

  def edit
    @merchant = User.find(params[:merchant_id])
    @item = Item.find(params[:id])
    @form_path = [:admin, @merchant, @item]
    render "/dashboard/items/edit"
  end

end
