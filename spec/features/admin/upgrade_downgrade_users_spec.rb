require 'rails_helper'

RSpec.describe 'Upgrade/Downgrade users', type: :feature do
  describe 'as an admin user' do
    before :each do
      @password = 'password'
      @admin_email = 'admin@email.com'
      @user_email = 'user@email.com'
      @merchant_email = 'merchant@email.com'
      admin = create(:admin, email: @admin_email, password: @password)
      @user = create(:user, email: @user_email, password: @password)
      create(:address, user: @user, default_address: true)
      @merchant = create(:merchant, email: @merchant_email, password: @password)
      create(:address, user: @merchant, default_address: true)

      visit login_path
      expect(page).to have_link('Log in')
      fill_in :email, with: @admin_email
      fill_in :password, with: @password
      click_button 'Log in'
    end

    it 'upgrades a regular user to a merchant' do
      visit admin_users_path
      expect(page).to have_content(@user.name)

      click_button 'Upgrade to Merchant'

      expect(current_path).to eq(admin_users_path)
      expect(page).to_not have_content(@user.name)

      visit logout_path
      visit login_path
      expect(page).to have_link('Log in')
      fill_in :email, with: @user_email
      fill_in :password, with: @password
      click_button 'Log in'
      expect(current_path).to eq(dashboard_path)
      visit merchants_path
      expect(page).to have_content(@user.name)
    end

    it 'downgrades a merchant to regular user' do
      visit merchants_path
      click_link @merchant.name
      expect(current_path).to eq(admin_merchant_path(@merchant))
      click_button 'Downgrade to User'

      expect(current_path).to eq(merchants_path)
      expect(page).to_not have_content(@merchant.name)
      visit admin_users_path
      expect(page).to have_content(@merchant.name)

      visit logout_path
      visit login_path
      expect(page).to have_link('Log in')
      fill_in :email, with: @merchant_email
      fill_in :password, with: @password
      click_button 'Log in'
      expect(current_path).to eq(profile_path)
      visit merchants_path
      within '#body-content-no-nav' do
        expect(page).to_not have_content(@merchant.name)
      end
    end
  end
end
