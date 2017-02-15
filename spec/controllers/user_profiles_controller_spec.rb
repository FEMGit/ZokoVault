require 'rails_helper'
require 'stripe_mock'

RSpec.describe UserProfilesController, type: :controller do
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

  let(:user) { create :user }
  let(:valid_attributes) do
    attributes_for(:user_profile)
      .merge(employers_attributes: {"0" => attributes_for(:employer) })
      .merge(user_id: user.id)
      .merge(email: "Email@email.com")
      .merge(subscription: {
        plan_id: plan.id,
        auto_resubscribe: false,
        stripe_token: stripe_helper.generate_card_token
      })
  end

  let(:invalid_attributes) do
    valid_attributes.merge({date_of_birth: ""})
  end

  before { sign_in user }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UserProfilesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #show" do
    it "assigns the requested user_profile as @user_profile" do
      user_profile = create(:user_profile, user: user)
      get :show, {}, session: valid_session
      expect(assigns(:user_profile)).to eq(user_profile)
    end
  end

  describe "GET #new" do
    it "assigns a new user_profile as @user_profile" do
      get :new, {}, session: valid_session
      expect(assigns(:user_profile)).to be_a_new(UserProfile)
    end
  end

  describe "GET #edit" do
    it "assigns the requested user_profile as @user_profile" do
      user_profile = create(:user_profile, user: user)
      get :edit, session: valid_session
      expect(assigns(:user_profile)).to eq(user_profile)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new UserProfile" do
        expect { post :create, {user_profile: valid_attributes}, session: valid_session }
          .to change(UserProfile, :count).by(1)
      end

      it "assigns a newly created user_profile as @user_profile" do
        post :create, {user_profile: valid_attributes}, session: valid_session
        expect(assigns(:user_profile)).to be_a(UserProfile)
        expect(assigns(:user_profile)).to be_persisted
      end

      it "redirects to the created user_profile" do
        post :create, {user_profile: valid_attributes}, session: valid_session
        expect(response).to redirect_to(user_profile_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved user_profile as @user_profile" do
        post :create, {user_profile: invalid_attributes}, session: valid_session
        expect(assigns(:user_profile)).to be_a_new(UserProfile)
      end

      it "re-renders the 'new' template" do
        post :create, {user_profile: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    let(:user_profile) do
      create(:user_profile, user: user)
    end

    context "with valid params" do
      let(:new_state) { "IL" }
      let(:new_attributes) { valid_attributes.merge(state: new_state) }

      it "updates the requested user_profile" do
        put :update, {id: user_profile.to_param, user_profile: new_attributes}, session: valid_session
        user_profile.reload
        expect(user_profile.state).to eq(new_state)
      end

      it "assigns the requested user_profile as @user_profile" do
        put :update, {id: user_profile.to_param, user_profile: new_attributes}, session: valid_session
        expect(assigns(:user_profile)).to eq(user_profile)
      end

      it "redirects to the user_profile" do
        put :update, {id: user_profile.to_param, user_profile: new_attributes}, session: valid_session
        expect(response).to redirect_to(user_profile_path)
      end
    end

    context "with invalid params" do
      it "assigns the user_profile as @user_profile" do
        put :update, {id: user_profile.to_param, user_profile: invalid_attributes}, session: valid_session
        expect(assigns(:user_profile)).to eq(user_profile)
      end

      it "re-renders the 'edit' template" do
        put :update, {id: user_profile.to_param, user_profile: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    before :each do @user_profile = create(:user_profile, user: user) end
    it "destroys the requested user_profile" do
      expect { delete :destroy, {id: @user_profile.to_param}, session: valid_session }
        .to change(UserProfile, :count).by(-1)
    end

    it "redirects to the user_profile list" do
      delete :destroy, {id: @user_profile.to_param}, session: valid_session
      expect(response).to redirect_to(@user_profile_url)
    end
  end
end
