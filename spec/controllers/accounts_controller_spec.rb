require 'rails_helper'

RSpec.describe AccountsController, type: :controller do


  let(:current_user) { create :user, user_profile: UserProfile.new }
  before do
    sign_in current_user
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:user_profile_attributes) do
        {
          signed_terms_of_service: 1, 
          security_questions_attributes: {
            0 => { question: 'foo', answer: 'bar' },
            1 => { question: 'baz', answer: 'quux' },
            2 => { question: 'q', answer: 'a' }
          },
          phone_number_raw:  "123-456-7890",
          mfa_frequency: :everytime,
        }
      end

      let(:user_attributes) do
        { user_profile_attributes: user_profile_attributes }
      end

      before do
        put :update, { user: user_attributes }
        current_user.reload
      end

      it "sets signed terms of service" do
        expect(current_user).to be_signed_terms_of_service
      end

      it "sets security questions" do
        expect(current_user.user_profile.security_questions.length).to eq 3
      end

      it "sets phone number without formatting" do
        expect(current_user.user_profile.phone_number).to eq "1234567890"
      end

      it "sets the multi-factor auth frequency to 'everytime'" do
        expect(current_user.user_profile.mfa_frequency).to eq 'everytime'
      end

      it "redirects to :show" do
        expect(response).to redirect_to(account_path)
      end

    end
  end
end
