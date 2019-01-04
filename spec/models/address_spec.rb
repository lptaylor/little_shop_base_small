require 'rails_helper'
RSpec.describe Address, type: :model do
    describe 'validations' do
      it { should validate_presence_of :address }
      it { should validate_presence_of :city }
      it { should validate_presence_of :state }
      it { should validate_presence_of :zip }
    end

    describe  'factory can make an address' do
      it 'makes address' do
        address_1 = create(:address)

        expect(address_1.class).to eq(Address)
      end
    end
end
