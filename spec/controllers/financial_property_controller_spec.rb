
require 'rails_helper'

RSpec.describe FinancialPropertyController, type: :controller do
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Property Name",
      property_type: "Commercial",
      notes: "Notes",
      value: 99.99,
      owner_id: contacts.first.id,
      address: "Address",
      city: "City",
      state: "State",
      zip: 55555,
      primary_contact_id: contacts.first.id,
      share_with_contact_ids: contacts.map(&:id),
      user_id: user.id
    }
  end
  
  let(:provider_attributes) do 
    {
      name: "Property Name",
      user_id: user.id
    }
  end
  
  let(:invalid_attributes) do
    { id: "", user_id: user.id }
  end

  before { 
    sign_in user 
    }

  let(:valid_session) { {} }
  
  describe "GET requests" do
    describe "GET #show" do
      it "assigns the requested financial property @financial_property" do
        financial_property = FinancialProperty.create! valid_attributes
        financial_provider = FinancialProvider.create! provider_attributes
        financial_provider.properties << financial_property
        get :show, { id: financial_property.to_param }, session: valid_session
        expect(assigns(:financial_property)).to eq(financial_property)
      end
    end

    describe "GET #new" do
      it "assigns a new financial property as @financial_property" do
        get :new, {}, session: valid_session
        expect(assigns(:financial_property)).to be_a_new(FinancialProperty)
      end
    end

    describe "GET #edit" do
      it "assigns the requested financial property as @financial_property" do
        financial_property = FinancialProperty.create! valid_attributes
        get :edit, { id: financial_property.to_param }, session: valid_session
        expect(assigns(:financial_property)).to eq(financial_property)
      end
    end
  end
  
  describe "POST #create" do
    context "with valid params" do
      it "creates a new financial property" do 
        expect { post :create, { financial_property: valid_attributes }, session: valid_session }
          .to change(FinancialProperty, :count).by(1)
      end
      
      it "shows correct flash message on create" do
        post :create, { financial_property: valid_attributes }, session: valid_session
        expect(flash[:success]).to be_present
      end
    end
    
    context "with valid attributes" do
      let(:financial_property) { assigns(:financial_property) }

      before do
        post :create, { financial_property: valid_attributes }, session: valid_session
      end

      it "assigns a newly created financial property as @financial_property" do
        expect(financial_property).to be_a(FinancialProperty)
        expect(financial_property).to be_persisted
      end
      
      it "assigns name" do
        expect(financial_property.name).to eq "Property Name"
      end
      
      it "assigns property_type" do
        expect(financial_property.property_type).to eq "Commercial"
      end
      
      it "assigns notes" do
        expect(financial_property.notes).to eq "Notes"
      end
      
      it "assigns value" do
        expect(financial_property.value.to_f).to eq 99.99
      end
      
      it "assigns owner" do
        expect(financial_property.owner).to eq contacts.first
      end
      
      it "assigns address" do
        expect(financial_property.address).to eq "Address"
      end
      
      it "assigns city" do
        expect(financial_property.city).to eq "City"
      end
      
      it "assigns state" do
        expect(financial_property.state).to eq "State"
      end
      
      it "assigns zip code" do
        expect(financial_property.zip).to eq 55555
      end
      
      it "assigns primary_contact" do
        expect(financial_property.primary_contact).to eq contacts.first
      end
      
      it "assigns share_with-contacts" do
        expect(financial_property.share_with_contacts).to eq contacts
      end
    end
    
    context "with invalid params" do
      it "assigns a newly created but unsaved financial property as @financial_property" do
        post :create, { financial_property: invalid_attributes }, session: valid_session
        expect(assigns(:financial_property)).to be_a(FinancialProperty)
      end

      it "re-renders the 'new' template" do
        post :create, { financial_property: invalid_attributes }, session: valid_session
        expect(response).to render_template :new
      end
    end
  end
 
  describe "PUT #update" do
    context "with valid params" do
      let(:new_valid_attributes) do
        {
          name: "Property Name New",
          web_address: "www.newzokuvault.com",
          property_type: "House",
          notes: "Notes New",
          value: 100,
          owner_id: contacts.second.id,
          address: "Address New",
          city: "City New",
          state: "State New",
          zip: 44444,
          phone_number: "888-888-8888",
          primary_contact_id: contacts.second.id,
          share_with_contact_ids: contacts.first(2).map(&:id),
          user_id: user.id
        }
      end
      
      let(:new_provider_attributes) do
        {
          user_id: user.id,
          name: "Property Name New",
        }
      end
      
      let(:financial_property) { assigns(:financial_property) }
      
      before do
        financial_provider = FinancialProvider.create! new_provider_attributes
        financial_property = FinancialProperty.create! valid_attributes
        financial_provider.properties << financial_property
        put :update, { id: financial_property.to_param, financial_property: new_valid_attributes }, session: valid_session
      end

      it "shows correct flash message on update" do
        expect(flash[:success]).to be_present
      end

      it "assigns the requested financial property as @financial_property" do
        expect(assigns(:financial_property)).to eq(financial_property)
      end
      
      it "assigns name" do
        expect(financial_property.name).to eq "Property Name New"
      end
      
      it "assigns Property_type" do
        expect(financial_property.property_type).to eq "House"
      end
      
      it "assigns notes" do
        expect(financial_property.notes).to eq "Notes New"
      end
      
      it "assigns value" do
        expect(financial_property.value.to_f).to eq 100
      end
      
      it "assigns owner" do
        expect(financial_property.owner).to eq contacts.second
      end
      
      it "assigns address" do
        expect(financial_property.address).to eq "Address New"
      end
      
      it "assigns city" do
        expect(financial_property.city).to eq "City New"
      end
      
      it "assigns state" do
        expect(financial_property.state).to eq "State New"
      end
      
      it "assigns zip code" do
        expect(financial_property.zip).to eq 44444
      end
      
      it "assigns primary_contact" do
        expect(financial_property.primary_contact).to eq contacts.second
      end
      
      it "assigns share_with-contacts" do
        expect(financial_property.share_with_contacts).to eq contacts.first(2)
      end
    end
  end
  
  describe "DELETE #destroy" do
    it "destroys the requested financial property and redirect to main financial information page" do
      
      financial_property = FinancialProperty.create! valid_attributes
      financial_provider = FinancialProvider.create! provider_attributes
      financial_provider.properties << financial_property
      expect { delete :destroy, { id: financial_property.to_param }, session: valid_session }
        .to change(FinancialProperty, :count).by(-1)
      expect(response).to redirect_to financial_information_path
    end

    it "shows correct flash message on destroy provider" do
      financial_property = FinancialProperty.create! valid_attributes
      financial_provider = FinancialProvider.create! provider_attributes
      financial_provider.properties << financial_property
      delete :destroy, { id: financial_property.to_param }, session: valid_session
      expect(flash[:notice]).to be_present
    end
  end
end