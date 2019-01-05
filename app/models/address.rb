class Address < ApplicationRecord
  belongs_to :user
  validates_presence_of :nickname, :address, :city, :state, :zip

end
