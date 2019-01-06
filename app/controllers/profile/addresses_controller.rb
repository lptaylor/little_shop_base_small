class Profile::AddressesController < ApplicationController
  # before_save :set_default

  def new
    @address = Address.new
  end

  def create
    @address = current_user.addresses.create(address_params)
    if @address.save
      redirect_to profile_path
      flash[:success] = "New Address Saved"
    else
      render :new
    end
  end

  def edit
    @address = Address.find(params[:format])
  end

  def update
    @address = Address.find(params[:format])
    @address.update(address_params)
      if @address.save
        flash[:success] = "Address has been updated"
        redirect_to profile_path(current_user)
      else
        render :edit
      end
  end

  def toggle_active_address
    @address = Address.find(params[:format])
    @address.toggle(:enabled).save
    redirect_to profile_path(current_user)
  end

  def toggle_default_address
    @existing_default = Address.find_by(default_address: true)
    @existing_default.toggle(:default_address).save
    @address = Address.find(params[:format])
    @address.toggle(:default_address).save
    redirect_to profile_path(current_user)
  end

  def toggle_shipping_address
    @address = Address.find(params[:format])
    @address.toggle(:shipping_address).save
    redirect_to cart_path
  end

end
private

def address_params
  params.require(:address).permit(:nickname, :address, :city, :state, :zip)
end

# def set_default_addresss
#   Address.where.not(id: id).update_all(default_address: false)
# end
#
# def set_shipping_addresss
#   Address.where.not(id: id).update_all(shipping_address: false)
# end
