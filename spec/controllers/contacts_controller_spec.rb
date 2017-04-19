require 'rails_helper'

RSpec.describe ContactsController, type: :controller do

  let(:user) { create(:user) }
  let(:valid_attributes) { { user: user, firstname: Faker::Name.first_name, emailaddress: Faker::Internet.free_email } }
  let(:user_profile) { UserProfile.create! user: user, date_of_birth: Time.now - 25.years }

  let(:invalid_attributes) { { firstname: nil } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ContactsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    user.user_profile = user_profile
    sign_in user
  end

  describe "GET #index" do
    it "assigns all contacts as @contacts" do
      contact = Contact.create! valid_attributes
      get :index, {}, session: valid_session
      expect(assigns(:contacts)).to eq([contact])
    end
  end

  describe "GET #show" do
    it "assigns the requested contact as @contact" do
      contact = Contact.create! valid_attributes
      get :show, {id: contact.to_param}, session: valid_session
      expect(assigns(:contact)).to eq(contact)
    end
  end

  describe "GET #new" do
    it "assigns a new contact as @contact" do
      get :new, {}, session: valid_session
      expect(assigns(:contact)).to be_a_new(Contact)
    end
  end

  describe "GET #edit" do
    it "assigns the requested contact as @contact" do
      contact = Contact.create! valid_attributes
      get :edit, {id: contact.to_param}, session: valid_session
      expect(assigns(:contact)).to eq(contact)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Contact" do
        expect {
          post :create, {contact: valid_attributes}, session: valid_session
        }.to change(Contact, :count).by(1)
      end

      it "assigns a newly created contact as @contact" do
        post :create, {contact: valid_attributes}, session: valid_session
        expect(assigns(:contact)).to be_a(Contact)
        expect(assigns(:contact)).to be_persisted
        expect(assigns(:contact).user).to eq user
      end

      it "shows correct flash message on create" do
        post :create, {contact: valid_attributes}, session: valid_session
        expect(flash[:success]).to be_present
      end

      it "redirects to the created contact" do
        post :create, {contact: valid_attributes}, session: valid_session
        expect(response).to redirect_to(Contact.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved contact as @contact" do
        post :create, {contact: invalid_attributes}, session: valid_session
        expect(assigns(:contact)).to be_a(Contact)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { firstname: Faker::Name.first_name } }

      it "updates the requested contact" do
        contact = Contact.create! valid_attributes
        put :update, {id: contact.to_param, contact: new_attributes}, session: valid_session
        contact.reload
        expect(contact.firstname).to eq(new_attributes[:firstname])
      end
      
      it "shows correct flash message on update" do
        contact = Contact.create! valid_attributes
        put :update, {id: contact.to_param, contact: valid_attributes}, session: valid_session
        expect(flash[:success]).to be_present
      end

      it "assigns the requested contact as @contact" do
        contact = Contact.create! valid_attributes
        put :update, {id: contact.to_param, contact: valid_attributes}, session: valid_session
        expect(assigns(:contact)).to eq(contact)
      end

      it "redirects to the contact" do
        contact = Contact.create! valid_attributes
        put :update, {id: contact.to_param, contact: valid_attributes}, session: valid_session
        expect(response).to redirect_to(contact)
      end
    end

    context "with invalid params" do
      it "assigns the contact as @contact" do
        contact = Contact.create! valid_attributes
        put :update, {id: contact.to_param, contact: invalid_attributes}, session: valid_session
        expect(assigns(:contact)).to eq(contact)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested contact" do
      contact = Contact.create! valid_attributes
      expect {
        delete :destroy, {id: contact.to_param}, session: valid_session
      }.to change(Contact, :count).by(-1)
    end

    it "redirects to the contacts list" do
      contact = Contact.create! valid_attributes
      delete :destroy, {id: contact.to_param}, session: valid_session
      expect(response).to redirect_to(contacts_url)
    end
    
    it "shows correct flash message on update" do
      contact = Contact.create! valid_attributes
      delete :destroy, {id: contact.to_param}, session: valid_session
      expect(flash[:notice]).to be_present
    end
  end

end
