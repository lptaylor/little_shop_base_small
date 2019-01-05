class Profile::AddressesController < ApplicationController

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
end


private

def address_params
  params.require(:address).permit(:nickname, :address, :city, :state, :zip)
end
