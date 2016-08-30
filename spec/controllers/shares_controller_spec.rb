require 'rails_helper'

RSpec.describe SharesController, type: :controller do
  let!(:user) { create :user }
  let!(:contact) { create :contact, user: user }
  let!(:document) { create :document }

  let(:valid_attributes) { { contact_id: contact.id, document_id: document.id, user: user } }
  let(:invalid_attributes) { { contact: contact } }

  let(:valid_session) { {} }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "assigns all shares as @shares" do
      share = Share.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:shares)).to eq([share])
    end
  end

  describe "GET #show" do
    it "assigns the requested share as @share" do
      share = Share.create! valid_attributes
      get :show, {id: share.to_param}, valid_session
      expect(assigns(:share)).to eq(share)
    end
  end

  describe "GET #new" do
    it "assigns a new share as @share" do
      get :new, { category: "foo", group: "bar" }, valid_session

      share = assigns(:share)

      expect(share).to be_a_new(Share)
    end
  end

  describe "GET #edit" do
    it "assigns the requested share as @share" do
      share = Share.create! valid_attributes
      get :edit, {id: share.to_param}, valid_session
      expect(assigns(:share)).to eq(share)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Share" do
        expect {
          post :create, {share: valid_attributes}, valid_session
        }.to change(Share, :count).by(1)
      end

      it "assigns a newly created share as @share" do
        post :create, {share: valid_attributes}, valid_session
        expect(assigns(:share)).to be_a(Share)
        expect(assigns(:share)).to be_persisted
        expect(assigns(:share).user).to eq(user)
      end

      it "redirects to the created share" do
        post :create, {share: valid_attributes}, valid_session
        expect(response).to redirect_to(assigns(:share))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved share as @share" do
        post :create, {share: invalid_attributes}, valid_session
        expect(assigns(:share)).to be_a_new(Share)
      end

      it "re-renders the 'new' template" do
        post :create, {share: invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: Faker::File.file_name, url: Faker::Internet.url } }

      it "updates the requested share" do
        share = Share.create! valid_attributes
        put :update, {id: share.to_param, share: new_attributes}, valid_session
        share.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested share as @share" do
        share = Share.create! valid_attributes
        put :update, {id: share.to_param, share: valid_attributes}, valid_session
        expect(assigns(:share)).to eq(share)
      end

      it "redirects to the share" do
        share = Share.create! valid_attributes
        put :update, {id: share.to_param, share: valid_attributes}, valid_session
        expect(response).to redirect_to(share)
      end
    end

    context "with invalid params" do
      it "assigns the share as @share" do
        share = Share.create! valid_attributes
        put :update, {id: share.to_param, share: invalid_attributes}, valid_session
        expect(assigns(:share)).to eq(share)
      end

      it "re-renders the 'edit' template" do
        share = Share.create! valid_attributes
        put :update, {id: share.to_param, share: invalid_attributes}, valid_session
        expect(response).to redirect_to(share)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested share" do
      share = Share.create! valid_attributes
      expect {
        delete :destroy, {id: share.to_param}, valid_session
      }.to change(Share, :count).by(-1)
    end

    it "redirects to the shares list" do
      share = Share.create! valid_attributes
      delete :destroy, {id: share.to_param}, valid_session
      expect(response).to redirect_to(shares_url)
    end
  end

end

