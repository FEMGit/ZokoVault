require 'rails_helper'

RSpec.describe FinancialAccountController, type: :controller do

  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Provider Name",
      web_address: "www.zokuvault.com",
      street_address: "Street",
      city: "City",
      state: "State",
      zip: 55555,
      phone_number: "777-777-7777",
      fax_number: "888-888-8888",
      primary_contact_id: contacts.first.id,
      share_with_contact_ids: contacts.map(&:id),
      user_id: user.id
    }
  end
  
  let(:account_0) do 
    {
      account_type: "Bond",
      owner_id: contacts.first.id,
      value: "99.99",
      primary_contact_broker_id: contacts.first.id,
      notes: "Notes",
      user_id: user.id
    }
  end

  let(:invalid_attributes) do
    { id: "", user_id: user.id }
  end

  before { sign_in user }

  let(:valid_session) { {} }

  describe "GET #show" do
    it "assigns the requested financial account provider as @financial_provider" do
      financial_account = FinancialAccountInformation.create! account_0
      financial_provider = FinancialProvider.create! valid_attributes
      financial_provider.accounts << financial_account
      get :show, { id: financial_provider.to_param }, session: valid_session
      expect(assigns(:financial_provider)).to eq(financial_provider)
      expect(assigns(:financial_provider).accounts.first).to eq(financial_account)
    end
  end
  
  describe "GET #new" do
    it "assigns a new financial account provider as @financial_provider" do
      get :new, {}, session: valid_session
      expect(assigns(:financial_provider)).to be_a_new(FinancialProvider)
    end
  end

  describe "GET #edit" do
    it "assigns the requested financial account provider as @financial_provider" do
      financial_provider = FinancialProvider.create! valid_attributes
      get :edit, { id: financial_provider.to_param }, session: valid_session
      expect(assigns(:financial_provider)).to eq(financial_provider)
    end
  end
  
  describe "POST #create" do
    context "with valid params" do
      it "creates a new financial provider" do 
        expect { post :create, { financial_provider: valid_attributes.merge(account_0: account_0) }, session: valid_session }
          .to change(FinancialProvider, :count).by(1)
      end
      
      it "shows correct flash message on create" do
        post :create, { financial_provider: valid_attributes.merge(account_0: account_0) }, session: valid_session
        expect(flash[:success]).to be_present
      end
    end
    
    context "with attributes" do
      let(:financial_provider) { assigns(:financial_provider) }

      before do
        post :create, {financial_provider: valid_attributes.merge(account_0: account_0)}, session: valid_session
      end

      it "assigns a newly created financial provider as @financial_provider" do
        expect(financial_provider).to be_a(FinancialProvider)
        expect(financial_provider).to be_persisted
      end
      
      it "assigns a newly created financial account as a part of @financial_provider.accounts" do
        expect(financial_provider.accounts.first).to be_a(FinancialAccountInformation)
        expect(financial_provider.accounts.first).to be_persisted
      end

      it "assigns name" do
        expect(financial_provider.name).to eq "Provider Name"
      end
        
      it "assigns web_address" do
        expect(financial_provider.web_address).to eq "www.zokuvault.com"
      end

      it "assigns city" do
        expect(financial_provider.city).to eq "City"
      end
      
      it "assigns state" do
        expect(financial_provider.state).to eq "State"
      end
        
      it "assigns zip" do
        expect(financial_provider.zip).to eq 55555
      end

      it "assigns phone_number" do
        expect(financial_provider.phone_number).to eq "777-777-7777"
      end

      it "assigns fax_number" do
        expect(financial_provider.fax_number).to eq "888-888-8888"
      end
      
      it "assigns primary contact" do
        expect(financial_provider.primary_contact).to eq contacts.first
      end
        
      it "assigns share with contacts" do
        expect(financial_provider.share_with_contacts).to eq contacts
      end
    end
    
    context "with invalid params" do
      it "assigns a newly created but unsaved financial provider as @financial_provider" do
        post :create, { financial_provider: invalid_attributes }, session: valid_session
        expect(assigns(:financial_provider)).to be_a(FinancialProvider)
      end

      it "re-renders the 'new' template" do
        post :create, { financial_provider: invalid_attributes }, session: valid_session
        expect(response).to render_template :new
      end
    end
  end
  
  describe "PUT #update" do
    context "with valid params" do
      let(:new_provider_attributes) do
        {
          name: "Provider Name New",
          web_address: "www.newzokuvault.com",
          street_address: "Street New",
          city: "City New",
          state: "State New",
          zip: 66666,
          phone_number: "444-444-4444",
          fax_number: "555-555-5555",
          primary_contact_id: contacts.second.id,
          share_with_contact_ids: contacts.first(2).map(&:id),
          user_id: user.id
        }
      end
  
      let(:new_account_attributes) do 
        {
          account_type: "Savings",
          owner_id: contacts.second.id,
          value: "100",
          primary_contact_broker_id: contacts.second.id,
          notes: "Notes New"
        }
      end
      
      let(:financial_provider) { assigns(:financial_provider) }
      
      before do
        financial_provider = FinancialProvider.create! valid_attributes
        put :update, { id: financial_provider.to_param, financial_provider: new_provider_attributes.merge(account_0: new_account_attributes) }, session: valid_session
      end

      it "shows correct flash message on update" do
        expect(flash[:success]).to be_present
      end

      it "assigns the requested financial provider as @financial_provider" do
        expect(assigns(:financial_provider)).to eq(financial_provider)
      end
      
      it "assigns the requested financial account type" do
        expect(assigns(:financial_provider).accounts.first.account_type).to eq "Savings"
      end
      
      it "assigns the requested financial account owner" do
        expect(assigns(:financial_provider).accounts.first.owner).to eq contacts.second
      end
      
      it "assigns the requested financial account value" do
        expect(assigns(:financial_provider).accounts.first.value.to_i).to eq 100
      end
      
      it "assigns the requested financial account primary contact" do
        expect(assigns(:financial_provider).accounts.first.primary_contact_broker).to eq contacts.second
      end
      
      it "assigns the requested financial account notes" do
        expect(assigns(:financial_provider).accounts.first.notes).to eq "Notes New"
      end

      it "redirects to the financial_provider" do
        expect(response).to redirect_to(show_account_url(financial_provider))
      end
    end
  end
  
  describe "DELETE #destroy" do
    before do
      request.env["HTTP_REFERER"] = "previous_page"
    end
    
    it "destroys the requested financial provider and redirect to main financial information page" do
      financial_provider = FinancialProvider.create! valid_attributes
      expect { delete :destroy_provider, { id: financial_provider.to_param }, session: valid_session }
        .to change(FinancialProvider, :count).by(-1)
      expect(response).to redirect_to financial_information_path
    end
    
    it "destroys the requested financial account and redirect to previous page" do
      financial_account = FinancialAccountInformation.create! account_0
      financial_provider = FinancialProvider.create! valid_attributes
      financial_provider.accounts << financial_account
      expect { delete :destroy, { id: financial_account.to_param }, session: valid_session }
        .to change(financial_provider.accounts, :count).by(-1)
      expect(response).to redirect_to "previous_page"
    end
    
    it "shows correct flash message on destroy provider" do
      financial_account = FinancialAccountInformation.create! account_0
      financial_provider = FinancialProvider.create! valid_attributes
      financial_provider.accounts << financial_account
      delete :destroy_provider, { id: financial_provider.to_param }, session: valid_session
      expect(flash[:notice]).to be_present
    end
    
    it "shows correct flash message on destroy account" do
      financial_account = FinancialAccountInformation.create! account_0
      financial_provider = FinancialProvider.create! valid_attributes
      financial_provider.accounts << financial_account
      delete :destroy, { id: financial_account.to_param }, session: valid_session
      expect(flash[:notice]).to be_present
    end
  end
end
