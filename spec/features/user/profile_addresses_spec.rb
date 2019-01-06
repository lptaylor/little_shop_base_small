require 'rails_helper'

describe 'As a user' do
  before(:each) do
    @user_1 = create(:user)
    @address_1 = create(:address, user: @user_1, default_address: true)
    @address_2 = create(:address, user: @user_1, default_address: false, enabled: false, shipping_address: false)
    @address_3 = create(:address, user: @user_1, default_address: false, shipping_address: false)
    @order_1 = create(:order, shipping_address: @address_2.id, status: 0, user_id: @user_1.id)
    @order_2 = create(:order, shipping_address: @address_1.id, status: 2, user_id: @user_1.id)
    @order_3 = create(:order, shipping_address: @address_1.id, status: 1, user_id: @user_1.id)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)
    visit profile_path(@user_1)
  end

  it 'allows user to add new addresses to existing addresses' do
    click_link 'Add New Address', new_profile_addresses_path(@user_1)

    nickname = "THIS IS A TEST"
    address = "12345 Main St 2"
    city = "Denver 2"
    state = "CO 2"
    zip = "80000 2"

    fill_in :address_nickname , with: nickname
    fill_in :address_address , with: address
    fill_in :address_city , with: city
    fill_in :address_state , with: state
    fill_in :address_zip , with: zip

    click_on 'Create Address'

    expect(current_path).to eq(profile_path)
    within ".address-#{@user_1.addresses.last.id}" do
      expect(page).to have_content(nickname)
      expect(page).to have_content(address)
      expect(page).to have_content(city)
      expect(page).to have_content(state)
      expect(page).to have_content(zip)
    end
  end

  it 'will not save an address with missing information' do
    click_link 'Add New Address', new_profile_addresses_path(@user_1)

    nickname = "THIS IS A TEST"
    address = "12345 Main St 2"
    city = "Denver 2"
    state = "CO 2"

    fill_in :address_nickname , with: nickname
    fill_in :address_address , with: address
    fill_in :address_city , with: city
    fill_in :address_state , with: state

    click_on 'Create Address'

    expect(current_path).to eq(profile_addresses_path)
    expect(page).to have_content("Add A New Address")
  end

  it 'will allow user to update address' do
    within '.default-address' do
      click_link 'Edit This Address', edit_profile_addresses_path(@user_1)
    end
    nickname = "THIS IS A TEST"
    address = "12345 Main St 2"
    city = "Denver 2"
    state = "CO 2"
    zip = "80000 2"

      fill_in :address_nickname , with: nickname
      fill_in :address_address , with: address
      fill_in :address_city , with: city
      fill_in :address_state , with: state
      fill_in :address_zip , with: zip

      click_on 'Update Address'

      expect(current_path).to eq(profile_path(@user_1))
      within '.default-address' do
        expect(page).to have_content(nickname)
        expect(page).to have_content(address)
        expect(page).to have_content(city)
        expect(page).to have_content(state)
        expect(page).to have_content(zip)
      end
  end

  it 'will not allow user to update address if details are empty' do
    within '.default-address' do
      click_link 'Edit This Address', profile_addresses_path(@user_1)
    end
    nickname = ""
    address = "12345 Main St 2"
    city = "Denver 2"
    state = "CO 2"
    zip = "80000 2"

      fill_in :address_nickname , with: nickname
      fill_in :address_address , with: address
      fill_in :address_city , with: city
      fill_in :address_state , with: state
      fill_in :address_zip , with: zip

      click_on 'Update Address'

      expect(page).to have_content("Nickname can't be blank")
  end

  it "will allow user to enable or disable" do
    within ".address-#{@address_2.id}" do
      expect(page).to have_button("Enable This Address")
      click_button "Enable This Address"
      expect(current_path).to eq(profile_path(@user_1))
      expect(@address_2.reload.enabled).to be true
    end
    within ".address-#{@address_3.id}" do
      expect(page).to have_button("Disable This Address")
      click_button "Disable This Address"
      expect(current_path).to eq(profile_path(@user_1))
      expect(@address_3.reload.enabled).to be false
    end
  end

  it "allows user to set a different default address and removes previous one" do
    within ".address-#{@address_3.id}" do
      expect(page).to have_button("Make This My Default Address")
      click_button "Make This My Default Address"
      expect(current_path).to eq(profile_path(@user_1))
    end

    within ".default-address" do
      expect(@address_3.reload.default_address).to be true
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
    end
  end

  it 'allows user to change address for order so long as it is just pending' do
    visit profile_order_path(@order_2)
    expect(page).to_not have_button("Change Shipping Address")
    visit profile_path(@user_1)
    visit profile_order_path(@order_3)
    expect(page).to_not have_button("Change Shipping Address")
    visit profile_path(@user_1)
    visit profile_order_path(@order_1)
    within ".order-address-#{@address_3.id}" do
      expect(@address_3.reload.shipping_address).to be false
      expect(page).to have_button("Change Shipping Address")
      click_button "Change Shipping Address"
      expect(@address_3.reload.shipping_address).to be true
      expect(page).to_not have_button("Change Shipping Address")
    end
  end
end
