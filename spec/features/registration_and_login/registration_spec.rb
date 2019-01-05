require 'rails_helper'

RSpec.describe 'Registration Workflow', type: :feature do
  it 'allows a visitor to register successfully when all data is entered properly' do
    visit registration_path
    email = "email@gmail.com"
    name = "Ian Douglas"
    nickname = "nickname 1"
    address = "123 Main St"
    city = "Denver"
    state = "CO"
    zip = "80000"

    fill_in :user_email,	with: email
    fill_in :user_password,	with: "password"
    fill_in :user_password_confirmation,	with: "password"
    fill_in :user_name,	with: name
    fill_in :user_addresses_attributes_0_nickname,	with: nickname
    fill_in :user_addresses_attributes_0_address,	with: address
    fill_in :user_addresses_attributes_0_city,	with: city
    fill_in :user_addresses_attributes_0_state,	with: state
    fill_in :user_addresses_attributes_0_zip,	with: zip
    click_button 'Create User'

    expect(current_path).to eq(profile_path)
    expect(page).to have_content('You are registered and logged in')
  end
  it 'makes the first address a visitor registers with as a default address ' do
    visit registration_path
    email = "email@gmail.com"
    name = "Ian Douglas"
    nickname = "nickname 1"
    address = "123 Main St"
    city = "Denver"
    state = "CO"
    zip = "80000"

    fill_in :user_email,	with: email
    fill_in :user_password,	with: "password"
    fill_in :user_password_confirmation,	with: "password"
    fill_in :user_name,	with: name
    fill_in :user_addresses_attributes_0_nickname,	with: nickname
    fill_in :user_addresses_attributes_0_address,	with: address
    fill_in :user_addresses_attributes_0_city,	with: city
    fill_in :user_addresses_attributes_0_state,	with: state
    fill_in :user_addresses_attributes_0_zip,	with: zip
    click_button 'Create User'

    expect(current_path).to eq(profile_path)
    expect(page).to have_content('You are registered and logged in')
    expect(page).to have_content("This is your default address")
  end
  describe 'blocks a visitor from registering' do
    scenario 'when details are missing' do
      visit registration_path

      click_button 'Create User'
      expect(current_path).to eq(users_path)
      expect(page).to have_content("Email can't be blank")
      expect(page).to have_content("Password can't be blank")
      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Addresses address can't be blank")
      expect(page).to have_content("Addresses city can't be blank")
      expect(page).to have_content("Addresses state can't be blank")
      expect(page).to have_content("Addresses zip can't be blank")
    end
    scenario 'when password confirmation is wrong' do
      visit registration_path

      email = "email@gmail.com"
      name = "Ian Douglas"
      address = "123 Main St"
      city = "Denver"
      state = "CO"
      zip = "80000"
      nickname = "nickname 1"

      fill_in :user_email,	with: email
      fill_in :user_password,	with: "password"
      fill_in :user_password_confirmation,	with: "different_password"
      fill_in :user_name,	with: name
      fill_in :user_addresses_attributes_0_nickname,	with: nickname
      fill_in :user_addresses_attributes_0_address,	with: address
      fill_in :user_addresses_attributes_0_city,	with: city
      fill_in :user_addresses_attributes_0_state,	with: state
      fill_in :user_addresses_attributes_0_zip,	with: zip
      click_button 'Create User'

      expect(current_path).to eq(users_path)
      expect(page).to have_content("Password confirmation doesn't match Password")
    end
    scenario 'when email is not unique' do
      email = "email@gmail.com"
      user = create(:user, email: email)

      visit registration_path

      fill_in :user_email,	with: email
      click_button 'Create User'

      expect(current_path).to eq(users_path)
      expect(page).to have_content('Email has already been taken')
    end
  end
end
