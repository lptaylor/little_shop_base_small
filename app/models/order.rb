class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items
  has_many :items, through: :order_items

  validates_presence_of :status

  enum status: [:pending, :completed, :cancelled]

  def shipping_address_details(shipping_address)
    user.addresses.find_by("addresses.id=?", shipping_address)
  end

  def self.top_3_states
    Order.joins(:user, :order_items, {user: :addresses})
      .select('addresses.state, count(order_items.id) as order_count')
      .where("order_items.fulfilled = ?", true)
      .group('addresses.state')
      .order('order_count desc, addresses.state asc')
      .limit(3)
  end

  def self.top_3_cities
    Order.joins(:user, :order_items, {user: :addresses})
      .select('addresses.city, addresses.state, count(order_items.id) as order_count')
      .where("order_items.fulfilled = ?", true)
      .group('addresses.state, addresses.city')
      .order('order_count desc, addresses.city asc, addresses.state asc')
      .limit(3)
  end

  def self.top_3_quantity_orders
    Order.joins(:user, :order_items)
      .select('users.name as user_name, sum(order_items.quantity) as total_quantity')
      .where('order_items.fulfilled=?', true)
      .order('total_quantity desc, user_name asc')
      .group(:id, 'users.id')
      .limit(3)
  end

  def last_update
    order_items.maximum(:updated_at)
  end

  def total_item_count
    order_items.sum(:quantity)
  end

  def total_cost
    oi = order_items.pluck("sum(quantity*price)")
    oi.sum
  end

  def my_item_count(merchant_id)
    self.order_items
      .joins(:item)
      .where("items.merchant_id=?", merchant_id)
      .pluck("sum(order_items.quantity)")
      .first.to_i
  end

  def my_revenue_value(merchant_id)
    self.order_items
      .joins(:item)
      .where("items.merchant_id=?", merchant_id)
      .pluck("sum(order_items.quantity * order_items.price)")
      .first.to_i
  end

  def my_items(merchant_id)
    Item.joins(order_items: :order)
      .where(
        :merchant_id => merchant_id,
        :"orders.id" => self.id,
        :"orders.status" => :pending
      )
  end

  def item_price(item_id)
    order_items.where(item_id: item_id).pluck(:price).first
  end

  def item_quantity(item_id)
    order_items.where(item_id: item_id).pluck(:quantity).first
  end

  def item_fulfilled?(item_id)
    order_items.where(item_id: item_id).pluck(:fulfilled).first
  end
end
