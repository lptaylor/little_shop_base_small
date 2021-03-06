require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :name }
  end

  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :orders }
    it { should have_many(:order_items).through(:orders) }
    it { should have_many :addresses }
  end

  describe 'class methods' do
    describe 'merchant stats' do
      before :each do
        @user_1 = create(:user)
        create(:address, user: @user_1, city: 'Denver', state: 'CO', default_address: true)
        @user_2 = create(:user)
        create(:address, user: @user_2, city: 'NYC', state: 'NY', default_address: true)
        @user_3 = create(:user)
        create(:address, user: @user_3, city: 'Seattle', state: 'WA', default_address: true)
        @user_4 = create(:user)
        create(:address, user: @user_4, city: 'Seattle', state: 'FL', default_address: true)

        @merchant_1, @merchant_2, @merchant_3 = create_list(:merchant, 3)
        create(:address, user: @merchant_1, default_address: true)
        create(:address, user: @merchant_2, default_address: true)
        create(:address, user: @merchant_3, default_address: true)

        @item_1 = create(:item, user: @merchant_1)
        @item_2 = create(:item, user: @merchant_2)
        @item_3 = create(:item, user: @merchant_3)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 100, price: 100, created_at: 10.minutes.ago, updated_at: 9.minute.ago)

        @order_2 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 300, price: 300, created_at: 2.days.ago, updated_at: 1.minute.ago)

        @order_3 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 200, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_4 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, item: @item_3, order: @order_4, quantity: 201, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)
      end
      it '.top_3_revenue_merchants' do
        expect(User.top_3_revenue_merchants[0]).to eq(@merchant_2)
        expect(User.top_3_revenue_merchants[0].revenue.to_f).to eq(90000.00)
        expect(User.top_3_revenue_merchants[1]).to eq(@merchant_3)
        expect(User.top_3_revenue_merchants[1].revenue.to_f).to eq(80200.00)
        expect(User.top_3_revenue_merchants[2]).to eq(@merchant_1)
        expect(User.top_3_revenue_merchants[2].revenue.to_f).to eq(10000.00)
      end
      it '.merchant_fulfillment_times' do
        expect(User.merchant_fulfillment_times(:asc, 1)).to eq([@merchant_1])
        expect(User.merchant_fulfillment_times(:desc, 2)).to eq([@merchant_2, @merchant_3])
      end
      it '.top_3_fulfilling_merchants' do
        expect(User.top_3_fulfilling_merchants[0]).to eq(@merchant_1)
        aft = User.top_3_fulfilling_merchants[0].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:01:00')
        expect(User.top_3_fulfilling_merchants[1]).to eq(@merchant_3)
        aft = User.top_3_fulfilling_merchants[1].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:05:00')
        expect(User.top_3_fulfilling_merchants[2]).to eq(@merchant_2)
        aft = User.top_3_fulfilling_merchants[2].avg_fulfillment_time
        expect(aft[0..13]).to eq('1 day 23:59:00')
      end
      it '.bottom_3_fulfilling_merchants' do
        expect(User.bottom_3_fulfilling_merchants[0]).to eq(@merchant_2)
        aft = User.bottom_3_fulfilling_merchants[0].avg_fulfillment_time
        expect(aft[0..13]).to eq('1 day 23:59:00')
        expect(User.bottom_3_fulfilling_merchants[1]).to eq(@merchant_3)
        aft = User.bottom_3_fulfilling_merchants[1].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:05:00')
        expect(User.bottom_3_fulfilling_merchants[2]).to eq(@merchant_1)
        aft = User.bottom_3_fulfilling_merchants[2].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:01:00')
      end
    end
  end

  describe 'instance methods' do
    it '.my_pending_orders' do
      merchants = create_list(:merchant, 2)
      item_1 = create(:item, user: merchants[0])
      item_2 = create(:item, user: merchants[1])
      orders = create_list(:order, 3)
      create(:order_item, order: orders[0], item: item_1, price: 1, quantity: 1)
      create(:order_item, order: orders[1], item: item_2, price: 1, quantity: 1)
      create(:order_item, order: orders[2], item: item_1, price: 1, quantity: 1)

      expect(merchants[0].my_pending_orders).to eq([orders[0], orders[2]])
      expect(merchants[1].my_pending_orders).to eq([orders[1]])
    end

    it '.inventory_check' do
      admin = create(:admin)
      user = create(:user)
      merchant = create(:merchant)
      item = create(:item, user: merchant, inventory: 100)

      expect(admin.inventory_check(item.id)).to eq(nil)
      expect(user.inventory_check(item.id)).to eq(nil)
      expect(merchant.inventory_check(item.id)).to eq(item.inventory)
    end

    describe 'merchant stats methods' do
      before :each do
        @user_1 = create(:user)
        create(:address, user: @user_1, city: 'Springfield', state: 'MO', default_address: true)
        @user_2 = create(:user)
        create(:address, user: @user_2, city: 'Springfield', state: 'CO', default_address: true)
        @user_3 = create(:user)
        create(:address, user: @user_3, city: 'Las Vegas', state: 'NV', default_address: true)
        @user_4 = create(:user)
        create(:address, user: @user_4, city: 'Denver', state: 'CO', default_address: true)

        @merchant = create(:merchant)
        @item_1, @item_2, @item_3, @item_4 = create_list(:item, 4, user: @merchant, inventory: 20)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1a = create(:fulfilled_order_item, order: @order_1, item: @item_1, quantity: 2, price: 100)

        @order_2 = create(:completed_order, user: @user_1)
        @oi_1b = create(:fulfilled_order_item, order: @order_2, item: @item_1, quantity: 1, price: 80)

        @order_3 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, order: @order_3, item: @item_2, quantity: 5, price: 60)

        @order_4 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, order: @order_4, item: @item_3, quantity: 3, price: 40)

        @order_5 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, order: @order_5, item: @item_4, quantity: 4, price: 20)
      end
      it '.top_items_by_quantity' do
        expect(@merchant.top_items_by_quantity(5)).to eq([@item_2, @item_4, @item_1, @item_3])
      end
      it '.quantity_sold_percentage' do
        expect(@merchant.quantity_sold_percentage[:sold]).to eq(15)
        expect(@merchant.quantity_sold_percentage[:total]).to eq(95)
        expect(@merchant.quantity_sold_percentage[:percentage]).to eq(15.79)
      end
      it '.top_3_states' do
        expect(@merchant.top_3_states.first.state).to eq('CO')
        expect(@merchant.top_3_states.first.quantity_shipped).to eq(9)
        expect(@merchant.top_3_states.second.state).to eq('MO')
        expect(@merchant.top_3_states.second.quantity_shipped).to eq(3)
        expect(@merchant.top_3_states.third.state).to eq('NV')
        expect(@merchant.top_3_states.third.quantity_shipped).to eq(3)
      end
      it '.top_3_cities' do
        expect(@merchant.top_3_cities.first.city).to eq('Springfield')
        expect(@merchant.top_3_cities.first.state).to eq('CO')
        expect(@merchant.top_3_cities.second.city).to eq('Denver')
        expect(@merchant.top_3_cities.second.state).to eq('CO')
        expect(@merchant.top_3_cities.third.city).to eq('Springfield')
        expect(@merchant.top_3_cities.third.state).to eq('MO')
      end
      it '.most_ordering_user' do
        expect(@merchant.most_ordering_user).to eq(@user_1)
        expect(@merchant.most_ordering_user.order_count).to eq(2)
      end
      it '.most_items_user' do
        expect(@merchant.most_items_user).to eq(@user_2)
        expect(@merchant.most_items_user.item_count).to eq(5)
      end
      it '.top_3_revenue_users' do
        expect(@merchant.top_3_revenue_users[0]).to eq(@user_2)
        expect(@merchant.top_3_revenue_users[0].revenue).to eq(300)
        expect(@merchant.top_3_revenue_users[1]).to eq(@user_1)
        expect(@merchant.top_3_revenue_users[1].revenue).to eq(280)
        expect(@merchant.top_3_revenue_users[2]).to eq(@user_3)
        expect(@merchant.top_3_revenue_users[2].revenue).to eq(120)
      end
    end
  end

  describe 'csv methods' do
    before(:each) do
      @user_1 = create(:user)
      create(:address, user: @user_1, city: 'Denver', state: 'CO', default_address: true)
      @user_2 = create(:user)
      create(:address, user: @user_2, city: 'NYC', state: 'NY', default_address: true)
      @user_3 = create(:user)
      create(:address, user: @user_3, city: 'Seattle', state: 'WA', default_address: true)
      @user_4 = create(:user)
      create(:address, user: @user_4, city: 'Seattle', state: 'FL', default_address: true)

      @merchant_1, @merchant_2, @merchant_3 = create_list(:merchant, 3)
      create(:address, user: @merchant_1, default_address: true)
      create(:address, user: @merchant_2, default_address: true)
      create(:address, user: @merchant_3, default_address: true)

      @item_1 = create(:item, user: @merchant_1)
      @item_2 = create(:item, user: @merchant_2)
      @item_3 = create(:item, user: @merchant_3)

      @order_1 = create(:completed_order, user: @user_1)
      @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 100, price: 100, created_at: 10.minutes.ago, updated_at: 9.minute.ago)

      @order_2 = create(:completed_order, user: @user_2)
      @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 300, price: 300, created_at: 2.days.ago, updated_at: 1.minute.ago)

      @order_3 = create(:completed_order, user: @user_3)
      @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 200, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

      @order_4 = create(:completed_order, user: @user_4)
      @oi_4 = create(:fulfilled_order_item, item: @item_3, order: @order_4, quantity: 201, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

      @order_5 = create(:completed_order, user: @user_1)
      @oi_5 = create(:fulfilled_order_item, item: @item_2, order: @order_5, quantity: 1, price: 50, created_at: 10.minutes.ago, updated_at: 5.minute.ago)
    end
    it 'returns list of current customers' do
      current_customers = [@user_1]
      expect(User.current_customers(@merchant_1)).to eq(current_customers)
    end
    it 'returns list of potential_customers' do
      potential_customers = [@user_2, @user_3, @user_4]
      expect(User.potential_customers(@merchant_1).to_a).to eq(potential_customers)
    end
    it '.customer_total_this_merchant' do
      expect(User.current_customers(@merchant_1).first.total_this_merchant).to eq(@oi_1.subtotal)
    end
    it '.customer_total_all_merchants_for_potential_customers' do
      total = (@oi_2.subtotal)
      expect(User.potential_customers(@merchant_1).first.total_all_merchants).to eq(total)
    end
    it '.customer_total_all_merchants_for_current_customers' do
      total = (@oi_1.subtotal + @oi_5.subtotal)
      expect(User.current_customers(@merchant_1).first.total_all_merchants).to eq(total)
    end
    it '.customer_total_number_orders_other_merchants' do
      expect(User.potential_customers(@merchant_1).first.total_orders).to eq(1)
    end
  end
  describe 'address methods' do
    before(:each) do
      @user_1 = create(:user)
      @address_1 = create(:address, user: @user_1, city: 'Denver', state: 'CO', default_address: false, shipping_address: true)
      @address_2 = create(:address, user: @user_1, city: 'Denver', state: 'CO', default_address: true, shipping_address: false)
      @user_2 = create(:user)
      create(:address, user: @user_2, city: 'NYC', state: 'NY', default_address: true, enabled: false)
      @user_3 = create(:user)
      @address_3 = create(:address, user: @user_3, city: 'Seattle', state: 'WA', default_address: true)
      @address_4 = create(:address, user: @user_3, city: 'Seattle', state: 'WA', default_address: false)
      @address_5 = create(:address, user: @user_3, city: 'Seattle', state: 'WA', default_address: false)
      @user_4 = create(:user)
      @address_6 = create(:address, user: @user_4, city: 'Seattle', state: 'FL', default_address: true)
      @address_7 = create(:address, user: @user_4, city: 'Seattle', state: 'WA', default_address: false, enabled: false)
      @address_8 = create(:address, user: @user_4, city: 'Seattle', state: 'WA', default_address: false, enabled: false)

    end
    it '.shipping_address' do
      expect(@user_1.shipping_address).to eq(@address_1)
      expect(@user_1.shipping_address).to_not eq(@address_2)
    end
    it 'any_active_addresses?' do
      expect(@user_1.any_active_addresses?).to be true
      expect(@user_2.any_active_addresses?).to be nil
    end
    it '.primary_address' do
      expect(@user_1.primary_address).to eq(@address_2)
      expect(@user_1.primary_address).to_not eq(@address_1)
    end
    it '.non_primary_addresses' do
      non_primary_addresses = [@address_4, @address_5]
      expect(@user_3.non_primary_addresses).to eq(non_primary_addresses)
    end
    it '.non_primary_addresses_active' do
      expect(@user_4.non_primary_addresses_active?).to be nil
      expect(@user_1.non_primary_addresses_active?).to be true
    end
  end
end
