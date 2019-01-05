require 'rails_helper'

RSpec.describe 'Admin User Show workflow', type: :feature do
  describe 'user show page' do
    before :each do
      admin = create(:admin)
      @user_1 = create(:user)
      create(:address, user: @user_1, default_address: true)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
    end
    it 'allows admin to see a user profile' do
      visit admin_users_path

      within "#user-#{@user_1.id}" do
        click_link(@user_1.name)
      end

      expect(current_path).to eq(admin_user_path(@user_1))

      expect(page).to have_content("Profile Page for #{@user_1.name}")
      expect(page).to have_content(@user_1.email)
      within '#address' do
        expect(page).to have_content(@user_1.primary_address.address)
        expect(page).to have_content("#{@user_1.primary_address.city}, #{@user_1.primary_address.state} #{@user_1.primary_address.zip}")
      end
      expect(page).to have_link('Edit Profile')
    end
    it 'allows admin to edit a user profile' do
      visit admin_user_path(@user_1)

      click_link 'Edit Profile'
      expect(current_path).to eq(edit_admin_user_path(@user_1))

      email = "email_2@gmail.com"
      name = "Ian Douglas 2"
      address = "123 Main St 2"
      city = "Denver 2"
      state = "CO 2"
      zip = "80000 2"
      nickname = "hello"

      fill_in :user_email,	with: email
      fill_in :user_password,	with: "new_password"
      fill_in :user_password_confirmation,	with: "new_password"
      fill_in :user_name,	with: name
      fill_in :user_addresses_attributes_0_nickname,	with: nickname
      fill_in :user_addresses_attributes_0_address,	with: address
      fill_in :user_addresses_attributes_0_city,	with: city
      fill_in :user_addresses_attributes_0_state,	with: state
      fill_in :user_addresses_attributes_0_zip,	with: zip
      click_button 'Update User'

      user_check = User.find(@user_1.id)
      user_address_check = user_check.primary_address
      expect(user_check.password_digest).to_not eq(@user_1.password_digest)

      expect(current_path).to eq(admin_user_path(@user_1))
      expect(page).to have_content("Profile Page for #{user_check.name}")
      expect(page).to have_content(user_check.email)
      within '#address' do
        expect(page).to have_content(user_address_check.address)
        expect(page).to have_content("#{user_address_check.city}, #{user_address_check.state} #{user_address_check.zip}")
      end
      expect(page).to have_content('Profile data updated')
    end
  end
end
