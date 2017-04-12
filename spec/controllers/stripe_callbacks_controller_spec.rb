require 'rails_helper'
require 'stripe_mock'
require 'support/stripe_callback_requests'

RSpec.describe StripeCallbacksController, type: :controller do
  let(:token) { ENV["STRIPE_CALLBACK_TOKEN"]}
  let(:valid_session) do 
    {
      'CONTENT_TYPE' => 'application/json', 
      'ACCEPT' => 'application/json',
      :key => ENV["STRIPE_CALLBACK_TOKEN"]
    }
  end
  
  let(:stripe_helper) { StripeMock.create_test_helper}
  before { StripeMock.start }
  after { StripeMock.stop }
  
  let!(:plan) do
    stripe_helper.create_plan(
      id: "test_plan",
      amount: 100,
      name: "test-monthly-zoku-plan"
    )
  end
  
  context "subscription callbacks" do
    before do
      callback_content = StripeCallbackRequests.subscription_created
      @request_body = callback_content.to_json
      @user = create(:user)
      @user.update(stripe_id: callback_content["data"]["object"]["customer"])
      Stripe::Customer.create(id: @user.stripe_id, email: @user.email)
    end
    
    describe "#subscription_created" do  
      it "updates the user's subscription info" do
        post :subscription_created, @request_body, valid_session
        expect(@user.subscription_status).to_not eq("paid")
        @user.reload
        expect(@user.subscription_status).to eq("paid")
      end
    end
    
    describe '#subscription_expired' do
      before do
        @request_body = StripeCallbackRequests.subscription_expired.to_json
      end
      
      it "sets the user's status to 'unpaid'" do
        @user.update(subscription_status: "paid")
        post :subscription_expired, @request_body, valid_session
        @user.reload
        expect(@user.subscription_status).to eq("unpaid")
      end
    end
  end
  
  context "payment_callbacks" do
    before do
      user = create(:user)
      cust_object = Stripe::Customer.create(email: user.email)
      user.update(stripe_id: cust_object.id)
      charge = Stripe::Charge.create(
        customer: user.stripe_id, 
        amount: 100, 
        currency: "usd"
      )
      body = StripeCallbackRequests.payment_success
      body["data"]["object"]["id"] = charge.id
      @request_body = body.to_json
    end
    
    describe '#payment_success' do
      it "saves a Payment object" do
        expect {
          post :payment_success, @request_body, valid_session
        }.to change { Payment.count }.by(1)
      end
    end
    
    describe '#payment_failure' do
      it "saves a failed Payment object" do
        expect {
          post :payment_failure, @request_body, valid_session
        }.to change { Payment.count }.by(1)
      end
    end
  end
  
  
end
