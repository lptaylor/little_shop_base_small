class Profile::AddressesController < ApplicationController

  def new
    @address = Address.new
  end


end
