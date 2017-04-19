require 'rails_helper'

RSpec.describe AccountsController, type: :controller do

  let(:current_user) { create :user, setup_complete: false, user_profile: UserProfile.new({date_of_birth: (Time.now - 25.years)}) }

  before do
    sign_in current_user
  end

  context "invalid user" do
    it "is redirected to accounts setup" do
      get :show
      expect(response).to redirect_to(setup_account_path)
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:user_profile_attributes) do
        {
          signed_terms_of_service: 1,
          security_questions_attributes: {
            "0" => { question: 'foo', answer: 'bar' },
            "1" => { question: 'baz', answer: 'quux' },
            "2" => { question: 'q', answer: 'a' }
          },
          phone_number_mobile: "123-456-7890",
          mfa_frequency: :always,
          date_of_birth: Date.today - 14.year
        }
      end

      let(:user_attributes) do
        { user_profile_attributes: user_profile_attributes }
      end

      before do
        put :update, { user: user_attributes }
        current_user.reload
      end

      it "sets setup_complete to true" do
        expect(current_user).to be_setup_complete
      end

      it "sets signed terms of service" do
        expect(current_user).to be_signed_terms_of_service
      end

      it "sets security questions" do
        expect(current_user.user_profile.security_questions.length).to eq 3
      end

      it "sets phone number without formatting" do
        expect(current_user.user_profile.phone_number_mobile).to eq "123-456-7890"
      end

      it "sets the multi-factor auth frequency to 'always'" do
        expect(current_user.user_profile.mfa_frequency).to eq 'always'
      end

      it "redirects to dashboard" do
        expect(response).to redirect_to(first_run_path)
      end
    end
  end
end
