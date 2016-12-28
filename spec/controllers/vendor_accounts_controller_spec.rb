require 'rails_helper'

RSpec.describe VendorAccountsController, type: :controller do
  before { sign_in create(:user) }

  # This should return the minimal set of attributes required to create a valid
  # VendorAccount. As you add validations to VendorAccount, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { attributes_for(:vendor_account) }

  let(:invalid_attributes) {
    skip("No validations for the model associated with this controller")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # VendorAccountsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all vendor_accounts as @vendor_accounts" do
      vendor_account = create(:vendor_account)
      get :index, {}, session: valid_session
      expect(assigns(:vendor_accounts)).to eq([vendor_account])
    end
  end

  describe "GET #show" do
    it "assigns the requested vendor_account as @vendor_account" do
      vendor_account = create(:vendor_account)
      get :show, {id: vendor_account.to_param}, session: valid_session
      expect(assigns(:vendor_account)).to eq(vendor_account)
    end
  end

  describe "GET #new" do
    it "assigns a new vendor_account as @vendor_account" do
      get :new, {}, session: valid_session
      expect(assigns(:vendor_account)).to be_a_new(VendorAccount)
    end
  end

  describe "GET #edit" do
    it "assigns the requested vendor_account as @vendor_account" do
      vendor_account = create(:vendor_account)
      get :edit, {id: vendor_account.to_param}, session: valid_session
      expect(assigns(:vendor_account)).to eq(vendor_account)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new VendorAccount" do
        expect {
          post :create, {vendor_account: valid_attributes}, session: valid_session
        }.to change(VendorAccount, :count).by(1)
      end

      it "assigns a newly created vendor_account as @vendor_account" do
        post :create, {vendor_account: valid_attributes}, session: valid_session
        expect(assigns(:vendor_account)).to be_a(VendorAccount)
        expect(assigns(:vendor_account)).to be_persisted
      end

      it "redirects to the created vendor_account" do
        post :create, {vendor_account: valid_attributes}, session: valid_session
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
      let(:new_name) { Faker::Company.name }
      let(:new_attributes) { valid_attributes.merge({ name: new_name}) }

      it "updates the requested vendor_account" do
        vendor_account = create(:vendor_account)
        put :update, {id: vendor_account.to_param, vendor_account: new_attributes}, session: valid_session
        vendor_account.reload
        expect(vendor_account.name).to eq(new_name)
      end

      it "assigns the requested vendor_account as @vendor_account" do
        vendor_account = create(:vendor_account)
        put :update, {id: vendor_account.to_param, vendor_account: new_attributes}, session: valid_session
        expect(assigns(:vendor_account)).to eq(vendor_account)
      end

      it "redirects to the vendor_account" do
        vendor_account = create(:vendor_account)
        put :update, {id: vendor_account.to_param, vendor_account: new_attributes}, session: valid_session
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
      vendor_account = create(:vendor_account)
      expect {
        delete :destroy, {id: vendor_account.to_param}, session: valid_session
      }.to change(VendorAccount, :count).by(-1)
    end

    it "redirects to the vendor_accounts list" do
      vendor_account = create(:vendor_account)
      delete :destroy, {id: vendor_account.to_param}, session: valid_session
      expect(response).to redirect_to(vendor_accounts_url)
    end
  end

end
