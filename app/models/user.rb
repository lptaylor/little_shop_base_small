class User < ApplicationRecord
  has_secure_password

  has_many :items, foreign_key: 'merchant_id'
  has_many :orders
  has_many :order_items, through: :orders
  has_many :addresses, :dependent => :destroy

  accepts_nested_attributes_for :addresses


  validates_presence_of :name
  validates :email, presence: true, uniqueness: true


  enum role: [:default, :merchant, :admin]

  def self.potential_customers_to_csv
  attributes = %w{name email total_all_merchants total_orders}

  CSV.generate(headers: true) do |csv|
    csv << attributes
    all.each do |user|
      csv << user.attributes.values_at(*attributes)
      end
    end
  end

  def self.current_customers_to_csv
  attributes = %w{name email total_this_merchant total_all_merchants}

  CSV.generate(headers: true) do |csv|
    csv << attributes
    all.each do |user|
      csv << user.attributes.values_at(*attributes)
      end
    end
  end

  def total_all_merchants
    order_items.sum("order_items.price * order_items.quantity")
  end

  def self.current_customers(merchant)
      joins(order_items: :item)
      .select("users.*, sum(order_items.price * order_items.quantity) as total_this_merchant")
      .where(role: "default")
      .where(active: true)
      .where("items.merchant_id = ?", merchant.id)
      .where("order_items.fulfilled = true")
      .group(:id)
  end

  def self.potential_customers(merchant)
      joins(orders: {order_items: :item})
      .select("users.*, count(orders.id) as total_orders, sum(order_items.price * order_items.quantity) as total_all_merchants")
      .where(role: "default")
      .where(active: true)
      .where.not(id: current_customers(merchant))
      .group(:id)
  end

  # def self.customer_total_all_merchants
  #   User.joins(:order_items)
  #       .select("users.*, sum(order_items.price * order_items.quantity) as total_all_merchants")
  #       .where("orders.status=?", 1)
  #       .where("users.role=?", 0)
  #       .where("users.active=?", true)
  #       .group(:id)
  # end

  # def self.customer_total_this_merchant(merchant_id)
  #   User.joins({order_items: :item})
  #       .select("users.*, sum(order_items.price * order_items.quantity) as total_this_merchant")
  #       .where("orders.status=?", 1)
  #       .where("items.merchant_id=?", merchant_id)
  #       .where("users.role=?", 0)
  #       .where("users.active=?", true)
  #       .group(:id)
  # end


  def shipping_address
    addresses.find_by(shipping_address: true)
  end

  def any_active_addresses?
    true if addresses.where(enabled: true).count > 0
  end

  def primary_address
    addresses.find_by(default_address: true)
  end

  def non_primary_addresses
    addresses.where(default_address: false)
  end

  def non_primary_addresses_active
    addresses.where(default_address: false)
    .where(enabled: true)
  end

  def self.top_3_revenue_merchants
    User.joins(items: :order_items)
      .select('users.*, sum(order_items.quantity * order_items.price) as revenue')
      .where('order_items.fulfilled=?', true)
      .order('revenue desc')
      .group(:id)
      .limit(3)
  end

  def self.merchant_fulfillment_times(order, count)
    User.joins(items: :order_items)
      .select('users.*, avg(order_items.updated_at - order_items.created_at) as avg_fulfillment_time')
      .where('order_items.fulfilled=?', true)
      .order("avg_fulfillment_time #{order}")
      .group(:id)
      .limit(count)
  end

  def self.top_3_fulfilling_merchants
    merchant_fulfillment_times(:asc, 3)
  end

  def self.bottom_3_fulfilling_merchants
    merchant_fulfillment_times(:desc, 3)
  end

  def my_pending_orders
    Order.joins(order_items: :item)
      .where("items.merchant_id=? AND orders.status=? AND order_items.fulfilled=?", self.id, 0, false)
  end

  def inventory_check(item_id)
    return nil unless self.merchant?
    Item.where(id: item_id, merchant_id: self.id).pluck(:inventory).first
  end

  def top_items_by_quantity(count)
    self.items
      .joins(:order_items)
      .select('items.*, sum(order_items.quantity) as quantity_sold')
      .where("order_items.fulfilled = ?", true)
      .group(:id)
      .order('quantity_sold desc')
      .limit(count)
  end

  def quantity_sold_percentage
    sold = self.items.joins(:order_items).where('order_items.fulfilled=?', true).sum('order_items.quantity')
    total = self.items.sum(:inventory) + sold
    {
      sold: sold,
      total: total,
      percentage: ((sold.to_f/total)*100).round(2)
    }
  end

  def top_3_states
    Item.joins('inner join order_items oi on oi.item_id=items.id inner join orders o on o.id=oi.order_id inner join users u on o.user_id=u.id inner join addresses a on a.user_id=u.id')
      .select('a.state, sum(oi.quantity) as quantity_shipped')
      .where("oi.fulfilled = ? AND items.merchant_id=? AND a.shipping_address=?",  true, self.id, true)
      .group(:state)
      .order('quantity_shipped desc')
      .limit(3)
  end

  def top_3_cities
    Item.joins('inner join order_items oi on oi.item_id=items.id inner join orders o on o.id=oi.order_id inner join users u on o.user_id=u.id inner join addresses a on a.user_id=u.id')
      .select('a.city, a.state, sum(oi.quantity) as quantity_shipped')
      .where("oi.fulfilled = ? AND items.merchant_id=? AND a.shipping_address=?", true, self.id, true)
      .group(:state, :city)
      .order('quantity_shipped desc')
      .limit(3)
  end

  def most_ordering_user
    User.joins('inner join orders o on o.user_id=users.id inner join order_items oi on oi.order_id=o.id inner join items i on i.id=oi.item_id')
      .select('users.*, count(o.id) as order_count')
      .where("oi.fulfilled = ? AND i.merchant_id=?", true, self.id)
      .group(:id)
      .order('order_count desc')
      .limit(1)
      .first
  end

  def most_items_user
    User.joins('inner join orders o on o.user_id=users.id inner join order_items oi on oi.order_id=o.id inner join items i on i.id=oi.item_id')
      .select('users.*, sum(oi.quantity) as item_count')
      .where("oi.fulfilled = ? AND i.merchant_id=?", true, self.id)
      .group(:id)
      .order('item_count desc')
      .limit(1)
      .first
  end

  def top_3_revenue_users
    User.joins('inner join orders o on o.user_id=users.id inner join order_items oi on oi.order_id=o.id inner join items i on i.id=oi.item_id')
      .select('users.*, sum(oi.quantity*oi.price) as revenue')
      .where("oi.fulfilled = ? AND i.merchant_id=?", true, self.id)
      .group(:id)
      .order('revenue desc')
      .limit(3)
  end
end
