require 'rails_helper'

describe 'As a merchant' do

  it 'shows the correct shipping information for different users orders' do
    merchant = create(:merchant)
    create(:address, user: merchant, default_address: true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

    user = create(:user)
    address_1 = create(:address, user: user, address:"123 Shady Glade" , default_address: true, shipping_address: true)
    order_1 = create(:order, user: user, shipping_address: user.shipping_address.id)
    visit dashboard_order_path(order_1)

    expect(page).to have_content(address_1.address)

    visit dashboard_path

    address_1.toggle(:shipping_address).save
    address_1.reload

    address_2 = create(:address, user: user, address:"This should work" , default_address: false, shipping_address: true)

    order_2 = create(:order, user: user, shipping_address: user.shipping_address.id)

    visit dashboard_order_path(order_2)

    expect(page).to have_content(address_2.city)
  end
end
