require 'rails_helper'

describe 'As a user' do
  before(:each) do
    @merchant = create(:merchant)
    @item = create(:item, user: @merchant)
    @user_1 = create(:user)
    @address_1 = create(:address, user: @user_1, default_address: true)
    @address_2 = create(:address, user: @user_1, default_address: false, enabled: false, shipping_address: false)
    @address_3 = create(:address, user: @user_1, default_address: false, shipping_address: false)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

    visit item_path(@item)
    click_button "Add to Cart"
    visit cart_path

  end

  it 'shows user only enabled addresses at checkout' do
    within '.default-address' do
      expect(page).to have_content(@address_1.nickname)
      expect(page).to have_content(@address_1.address)
      expect(page).to have_content(@address_1.city)
      expect(page).to have_content(@address_1.state)
      expect(page).to have_content(@address_1.zip)
    end

    within '.secondary-addresses' do
      expect(page).to have_content(@address_3.nickname)
      expect(page).to have_content(@address_3.address)
      expect(page).to have_content(@address_3.city)
      expect(page).to have_content(@address_3.state)
      expect(page).to have_content(@address_3.zip)
      expect(page).to_not have_content(@address_1.nickname)
      expect(page).to_not have_content(@address_1.address)
      expect(page).to_not have_content(@address_1.city)
      expect(page).to_not have_content(@address_1.state)
      expect(page).to_not have_content(@address_1.zip)
      expect(page).to_not have_content(@address_2.nickname)
      expect(page).to_not have_content(@address_2.address)
      expect(page).to_not have_content(@address_2.city)
      expect(page).to_not have_content(@address_2.state)
      expect(page).to_not have_content(@address_2.zip)
    end
  end

end
