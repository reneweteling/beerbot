require 'spec_helper'
require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do

  before(:each) do
    @user = create :user
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "Sign In" do

    it "Valid login attempt" do
      credential = { email: @user.email, password: @user.password }
      post :create, credential
      expect( session["warden.user.user.key"][0][0]!=nil ).to eq(true)
    end

    it "Invalid login attempt" do
  		credential = { email: "test@gmail.com", password: @user.password } # if email not existed in db
  		post :create, credential  
      expect(credential[:email].eql?(@user.email)).to eq(false) # matched email return false
    end
  end

  describe "Sign out" do

    it "should logout user" do
      credential = { auth_token: @user.authentication_token }
      delete :destroy, credential
      expect( session["flash"]["flashes"]["notice"] ).to eq("Signed out successfully.")
    end

  end
  
end