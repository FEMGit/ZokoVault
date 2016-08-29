require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Document. As you add validations to Document, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DocumentsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let (:user) do
    user = User.find_or_initialize_by(email: "user@zokuvault.com")
    user.password = user.password_confirmation = "password"
    user.confirmed_at = Time.now
    user.save
    user
  end

  before do
    sign_in user
  end

  describe "GET #index" do
    it "assigns all documents as @documents" do
      document = Document.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:documents)).to eq([document])
    end
  end

  describe "GET #show" do
    it "assigns the requested document as @document" do
      document = Document.create! valid_attributes
      get :show, params: {id: document.to_param}, session: valid_session
      expect(assigns(:document)).to eq(document)
    end
  end

  describe "GET #new" do
    it "assigns a new document as @document" do
      get :new, params: {}, session: valid_session
      expect(assigns(:document)).to be_a_new(Document)
    end
  end

  describe "GET #edit" do
    it "assigns the requested document as @document" do
      document = Document.create! valid_attributes
      get :edit, params: {id: document.to_param}, session: valid_session
      expect(assigns(:document)).to eq(document)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Document" do
        expect {
          post :create, params: {document: valid_attributes}, session: valid_session
        }.to change(Document, :count).by(1)
      end

      it "assigns a newly created document as @document" do
        post :create, params: {document: valid_attributes}, session: valid_session
        expect(assigns(:document)).to be_a(Document)
        expect(assigns(:document)).to be_persisted
      end

      it "redirects to the created document" do
        post :create, params: {document: valid_attributes}, session: valid_session
        expect(response).to redirect_to(Document.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved document as @document" do
        post :create, params: {document: invalid_attributes}, session: valid_session
        expect(assigns(:document)).to be_a_new(Document)
      end

      it "re-renders the 'new' template" do
        post :create, params: {document: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested document" do
        document = Document.create! valid_attributes
        put :update, params: {id: document.to_param, document: new_attributes}, session: valid_session
        document.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested document as @document" do
        document = Document.create! valid_attributes
        put :update, params: {id: document.to_param, document: valid_attributes}, session: valid_session
        expect(assigns(:document)).to eq(document)
      end

      it "redirects to the document" do
        document = Document.create! valid_attributes
        put :update, params: {id: document.to_param, document: valid_attributes}, session: valid_session
        expect(response).to redirect_to(document)
      end
    end

    context "with invalid params" do
      it "assigns the document as @document" do
        document = Document.create! valid_attributes
        put :update, params: {id: document.to_param, document: invalid_attributes}, session: valid_session
        expect(assigns(:document)).to eq(document)
      end

      it "re-renders the 'edit' template" do
        document = Document.create! valid_attributes
        put :update, params: {id: document.to_param, document: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested document" do
      document = Document.create! valid_attributes
      expect {
        delete :destroy, params: {id: document.to_param}, session: valid_session
      }.to change(Document, :count).by(-1)
    end

    it "redirects to the documents list" do
      document = Document.create! valid_attributes
      delete :destroy, params: {id: document.to_param}, session: valid_session
      expect(response).to redirect_to(documents_url)
    end
  end

end

