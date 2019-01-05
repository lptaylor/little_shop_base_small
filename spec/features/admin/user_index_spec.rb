require 'rails_helper'

RSpec.describe 'Admin User Index workflow', type: :feature do
  describe 'user index page' do
    before :each do
      admin = create(:admin)
      @user_1 = create(:user)
      @user_2 = create(:inactive_user)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
    end
    it 'displays a list of all regular users' do
      merchant = create(:merchant)
      admin2 = create(:admin)
      visit admin_users_path

      within "#user-#{@user_1.id}" do
        expect(page).to have_link(@user_1.name)
        expect(page).to have_content(@user_1.created_at)
        expect(page).to have_button('Disable')
      end
      within "#user-#{@user_2.id}" do
        expect(page).to have_link(@user_2.name)
        expect(page).to have_content(@user_2.created_at)
        expect(page).to have_button('Enable')
      end
      expect(page).to_not have_content(merchant.name)
      expect(page).to_not have_content(admin2.name)
    end
    it 'allows admin to enable an inactive user' do
      visit admin_users_path

      within "#user-#{@user_2.id}" do
        click_button 'Enable'
      end
      expect(current_path).to eq(admin_users_path)

      within "#user-#{@user_2.id}" do
        expect(page).to have_button('Disable')
      end
    end
    it 'allows admin to disable an active user' do
      visit admin_users_path

      within "#user-#{@user_1.id}" do
        click_button 'Disable'
      end
      expect(current_path).to eq(admin_users_path)

      within "#user-#{@user_1.id}" do
        expect(page).to have_button('Enable')
      end
    end
  end
end
