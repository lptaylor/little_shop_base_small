FactoryBot.define do
  factory :address, class: Address do
    sequence(:address) { |n| "Address #{n}" }
    sequence(:city) { |n| "City #{n}" }
    sequence(:state) { |n| "State #{n}" }
    sequence(:zip) { |n| "Zip #{n}" }
    default_address { true }
    enabled { true }
    shipping_address { true }
  end

  factory :secondary_address, parent: :address do
    default_address { false }
    enabled { true }
    shipping_address { false }
  end

  factory :disabled_address, parent: :address do
    default_address { false }
    enabled { true }
  end
end
