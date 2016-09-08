require 'rails_helper'

RSpec.describe VendorAccountsController, type: :controller do
  before { sign_in create(:user) }

  # This should return the minimal set of attributes required to create a valid
  # VendorAccount. As you add validations to VendorAccount, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # VendorAccountsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all vendor_accounts as @vendor_accounts" do
      vendor_account = VendorAccount.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:vendor_accounts)).to eq([vendor_account])
    end
  end

  describe "GET #show" do
    it "assigns the requested vendor_account as @vendor_account" do
      vendor_account = VendorAccount.create! valid_attributes
      get :show, params: {id: vendor_account.to_param}, session: valid_session
      expect(assigns(:vendor_account)).to eq(vendor_account)
    end
  end

  describe "GET #new" do
    it "assigns a new vendor_account as @vendor_account" do
      get :new, params: {}, session: valid_session
      expect(assigns(:vendor_account)).to be_a_new(VendorAccount)
    end
  end

  describe "GET #edit" do
    it "assigns the requested vendor_account as @vendor_account" do
      vendor_account = VendorAccount.create! valid_attributes
      get :edit, params: {id: vendor_account.to_param}, session: valid_session
      expect(assigns(:vendor_account)).to eq(vendor_account)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new VendorAccount" do
        expect {
          post :create, params: {vendor_account: valid_attributes}, session: valid_session
        }.to change(VendorAccount, :count).by(1)
      end

      it "assigns a newly created vendor_account as @vendor_account" do
        post :create, params: {vendor_account: valid_attributes}, session: valid_session
        expect(assigns(:vendor_account)).to be_a(VendorAccount)
        expect(assigns(:vendor_account)).to be_persisted
      end

      it "redirects to the created vendor_account" do
        post :create, params: {vendor_account: valid_attributes}, session: valid_session
        expect(response).to redirect_to(VendorAccount.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved vendor_account as @vendor_account" do
        post :create, params: {vendor_account: invalid_attributes}, session: valid_session
        expect(assigns(:vendor_account)).to be_a_new(VendorAccount)
      end

      it "re-renders the 'new' template" do
        post :create, params: {vendor_account: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested vendor_account" do
        vendor_account = VendorAccount.create! valid_attributes
        put :update, params: {id: vendor_account.to_param, vendor_account: new_attributes}, session: valid_session
        vendor_account.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested vendor_account as @vendor_account" do
        vendor_account = VendorAccount.create! valid_attributes
        put :update, params: {id: vendor_account.to_param, vendor_account: valid_attributes}, session: valid_session
        expect(assigns(:vendor_account)).to eq(vendor_account)
      end

      it "redirects to the vendor_account" do
        vendor_account = VendorAccount.create! valid_attributes
        put :update, params: {id: vendor_account.to_param, vendor_account: valid_attributes}, session: valid_session
        expect(response).to redirect_to(vendor_account)
      end
    end

    context "with invalid params" do
      it "assigns the vendor_account as @vendor_account" do
        vendor_account = VendorAccount.create! valid_attributes
        put :update, params: {id: vendor_account.to_param, vendor_account: invalid_attributes}, session: valid_session
        expect(assigns(:vendor_account)).to eq(vendor_account)
      end

      it "re-renders the 'edit' template" do
        vendor_account = VendorAccount.create! valid_attributes
        put :update, params: {id: vendor_account.to_param, vendor_account: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested vendor_account" do
      vendor_account = VendorAccount.create! valid_attributes
      expect {
        delete :destroy, params: {id: vendor_account.to_param}, session: valid_session
      }.to change(VendorAccount, :count).by(-1)
    end

    it "redirects to the vendor_accounts list" do
      vendor_account = VendorAccount.create! valid_attributes
      delete :destroy, params: {id: vendor_account.to_param}, session: valid_session
      expect(response).to redirect_to(vendor_accounts_url)
    end
  end

end
