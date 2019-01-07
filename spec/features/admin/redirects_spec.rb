require 'rails_helper'

RSpec.describe 'Admin redirects', type: :feature do
  before :each do
    admin = create(:admin)
    @merchant = create(:merchant)
    @user = create(:user)
    create(:address, user: @user, default_address: true)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
  end
  it 'redirects to user profile if account is merchant' do
    visit admin_merchant_path(@user)
    expect(current_path).to eq(admin_user_path(@user))
  end
  it 'redirects to merchant dashboard if account is user' do
    visit admin_user_path(@merchant)
    expect(current_path).to eq(admin_merchant_path(@merchant))
  end
end
