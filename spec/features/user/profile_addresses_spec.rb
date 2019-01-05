require 'rails_helper'

describe 'As a user' do
  before(:each) do
    @user_1 = create(:user)
    create(:address, user: @user_1, default_address: true)
    create(:address, user: @user_1, default_address: false, enabled: false)
    create(:address, user: @user_1, default_address: false)
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

  it 'it will not save an address with missing information' do
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

end
