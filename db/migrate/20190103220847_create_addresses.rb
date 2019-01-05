class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.string :nickname
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.boolean :default_address, default: false
      t.boolean :enabled , default: true
      t.boolean :shipping_address, default: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
