require 'rails_helper'

RSpec.describe UserProfilesController, type: :controller do

  let(:user) { create :user }
  let(:valid_attributes) do
    attributes_for(:user_profile)
      .merge(employers_attributes: [attributes_for(:employer)])
      .merge(user_id: user.id)
      .merge(email: "Email@email.com")
  end

  let(:invalid_attributes) do
    skip("Add a hash of attributes invalid for your model")
  end

  before { sign_in user }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UserProfilesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #show" do
    it "assigns the requested user_profile as @user_profile" do
      user_profile = UserProfile.create! valid_attributes.merge(user: user)
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
      user_profile = UserProfile.create! valid_attributes.merge(user: user)
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
    context "with valid params" do
      let(:user_profile) do
        UserProfile.create! valid_attributes.merge(user: user)
      end

      let(:new_attributes) do
        skip("Add a hash of attributes valid for your model")
      end

      it "updates the requested user_profile" do
        put :update, {id: user_profile.to_param, user_profile: new_attributes}, session: valid_session
        user_profile.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested user_profile as @user_profile" do
        put :update, {id: user_profile.to_param, user_profile: valid_attributes}, session: valid_session
        expect(assigns(:user_profile)).to eq(user_profile)
      end

      it "redirects to the user_profile" do
        put :update, {id: user_profile.to_param, user_profile: valid_attributes}, session: valid_session
        expect(response).to redirect_to(user_profile_path)
      end
    end

    context "with invalid params" do
      let(:user_profile) do
        UserProfile.create! valid_attributes.merge(user: user)
      end

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

  xdescribe "DELETE #destroy" do
    it "destroys the requested user_profile" do
      user_profile = UserProfile.create! valid_attributes
      expect { delete :destroy, {id: user_profile.to_param}, session: valid_session }
        .to change(UserProfile, :count).by(-1)
    end

    it "redirects to the user_profile list" do
      user_profile = UserProfile.create! valid_attributes
      delete :destroy, {id: user_profile.to_param}, session: valid_session
      expect(response).to redirect_to(user_profile_url)
    end
  end
end
