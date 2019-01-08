require 'rails_helper'

describe 'As a Merchant' do
  before(:each) do
    @user_1 = create(:user)
    create(:address, user: @user_1)
    @merchant_1 = create(:user, role: 1)
    create(:address, user: @merchant_1)
    @merchant_2 = create(:user, role: 1)
    create(:address, user: @merchant_2)

    @item_1 = create(:item, price: 25.00, user: @merchant_1)
    @item_2 = create(:item, price: 50.00, user: @merchant_1)
    @item_3 = create(:item, price: 50.00, user: @merchant_2)
    @items = [@item_1, @item_2, @item_3]

    @order_1 = create(:completed_order, user: @user_1, shipping_address: @user_1.shipping_address.id)
    @order_2 = create(:completed_order, user: @user_1, shipping_address: @user_1.shipping_address.id)
    @order_3 = create(:completed_order, user: @user_1, shipping_address: @user_1.shipping_address.id)

    @order_item_1 = create(:fulfilled_order_item, order: @order_1, item: @items[0], price: 25, quantity: 2)
    @order_item_2 = create(:fulfilled_order_item, order: @order_2, item: @items[1], price: 50, quantity: 2)
    @order_item_3 = create(:fulfilled_order_item, order: @order_3, item: @items[2], price: 50, quantity: 2)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)
    visit dashboard_path

  end
  it 'shows me a link to download existing customers data' do
    within '.current-customers' do
      expect(page).to have_content("Click here to download your current cutomers info:")
      expect(page).to have_link("Export to csv")
    end

    within '.potential-customers' do
      expect(page).to have_content("Click here to download potential cutomers info:")
      expect(page).to have_link("Export to csv")
    end
  end
end
