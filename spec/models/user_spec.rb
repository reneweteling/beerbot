require 'rails_helper'

describe User, type: :model do

  before do
		@user = create(:user)
    create(:beer, user: @user, amount: 1)
    create(:beer, user: @user, amount: -4)
	end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_presence_of(:password_confirmation) }
  end

  describe "Associations" do
    it { is_expected.to have_many(:beers) }
  end

  describe "String Conversion" do
  	it "Firstname" do      
  		expect(@user.to_s).to eq(@user.first_name)
  	end
  end

  describe "Update Counter" do
  	it "Update" do
  		expect(@user.update_counters).to eq(true) #update the data
      expect(@user.beer_total).to eq(-3) #expected result
  	end
	end

end
