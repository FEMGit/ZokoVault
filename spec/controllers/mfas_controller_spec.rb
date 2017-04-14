require 'rails_helper'

RSpec.describe MfasController, type: :controller do
  let(:current_user) { create :user, setup_complete: true, user_profile: UserProfile.new({date_of_birth: (Time.now - 25.years)}) }

  before do
    sign_in current_user
  end

  describe "GET #show" do
    context "authenticated" do
      let(:session) { {mfa: true } }
      it "redirects" do
        get :show, {}, session
        expect(response).to redirect_to(root_path)
      end
    end

    it "shows the form" do
      allow_any_instance_of(MultifactorAuthenticator).to receive(:send_code)
      get :show
      expect(response).to render_template(:show)
    end
  end

  describe "POST #update" do
    it "redirects back to form on fail" do
      allow_any_instance_of(MultifactorAuthenticator).to receive(:verify_code)
        .with('123').and_return(false)
      post :create, { phone_code: '123' }
      expect(response).to redirect_to(mfa_path)
    end

    it "redirects to root on success" do
      allow_any_instance_of(MultifactorAuthenticator).to receive(:verify_code)
        .with('1234').and_return(true)
      post :create, { phone_code: '1234' }
      expect(session[:mfa]).to be_truthy
      expect(response).to redirect_to(root_path)
    end
  end

end
