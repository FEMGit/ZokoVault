require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end


  context "after successful registartion" do
    let(:user_params) do
      {
        email: Faker::Internet.free_email,
        password: 'password',
        password: 'password',
        user_profile_attributes: {
          first_name: Faker::Name.first_name, 
          middle_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name, 
          date_of_birth: 30.years.ago
        }
      }

    end
    it "creates  user" do
      expect { post :create, { user: user_params } }.to change { User.count }.by(1)
    end

    it "creates user_profile" do
      expect { post :create, { user: user_params } }.to change { UserProfile.count }.by(1)
    end

    it "redirects to thank you page" do
      post :create, { user: user_params }
      expect(response).to redirect_to(thank_you_path)
    end
  end

end
