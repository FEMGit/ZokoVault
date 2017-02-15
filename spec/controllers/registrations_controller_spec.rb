require 'rails_helper'
require 'stripe_mock'

RSpec.describe RegistrationsController, type: :controller do

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }
  
  let!(:plan) do
    stripe_helper.create_plan(
      id: "test_plan",
      amount: 100,
      name: "test-monthly-zoku-plan"
    )
  end

  context "after successful registartion" do
    let(:valid_params) do
      {
        user: {
          email: Faker::Internet.free_email,
          password: 'fgfdfGFGGF56@%FSfghhfasgd5',
          user_profile_attributes: {
            first_name: Faker::Name.first_name, 
            middle_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name, 
            date_of_birth: 30.years.ago
          }
        },
        stripe_token: stripe_helper.generate_card_token,
        plan_id: plan.id,
      }

    end
    it "creates  user" do
      expect { post :create, valid_params }.to change { User.count }.by(1)
    end

    it "creates user_profile" do
      expect { post :create, valid_params }.to change { UserProfile.count }.by(1)
    end

    it "redirects to thank you page" do
      post :create, valid_params
      expect(response).to redirect_to(thank_you_path)
    end
  end

end
