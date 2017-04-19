require 'rails_helper'

RSpec.describe FinancialAlternativeController, type: :controller do

  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Provider Name",
      provider_type: "Alternative",
      web_address: "www.zokuvault.com",
      street_address: "Street",
      city: "City",
      state: "IL",
      zip: 55555,
      phone_number: "777-777-7777",
      fax_number: "888-888-8888",
      primary_contact_id: contacts.first.id,
      share_with_contact_ids: contacts.map(&:id),
      user_id: user.id
    }
  end
  
  let(:alternative_0) do 
    {
      alternative_type: "Venture Capital",
      name: "Investment Name",
      commitment: "99.99",
      total_calls: "99.99",
      total_distributions: "99.99",
      current_value: "99.99",
      primary_contact_id: contacts.first.id,
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
    it "assigns the requested financial alternative provider as @financial_provider" do
      financial_alternative = FinancialAlternative.create! alternative_0
      financial_alternative.account_owner_ids = (AccountPolicyOwner.create contact_id: contacts.first.id, contactable_id: financial_alternative.id,
                                                                       contactable_type: financial_alternative.class).id
      financial_provider = FinancialProvider.create! valid_attributes
      financial_provider.alternatives << financial_alternative
      get :show, { id: financial_provider.to_param }, session: valid_session
      expect(assigns(:financial_provider)).to eq(financial_provider)
      expect(assigns(:financial_provider).alternatives.first).to eq(financial_alternative)
    end
  end
  
  describe "GET #new" do
    it "assigns a new financial alternative provider as @financial_provider" do
      get :new, {}, session: valid_session
      expect(assigns(:financial_provider)).to be_a_new(FinancialProvider)
    end
  end

  describe "GET #edit" do
    it "assigns the requested financial alternative provider as @financial_provider" do
      financial_provider = FinancialProvider.create! valid_attributes
      get :edit, { id: financial_provider.to_param }, session: valid_session
      expect(assigns(:financial_provider)).to eq(financial_provider)
    end
  end
  
  describe "POST #create" do
    context "with valid params" do
      it "creates a new financial provider" do 
        expect { post :create, { financial_provider: valid_attributes.merge(alternative_0: alternative_0) }, session: valid_session }
          .to change(FinancialProvider, :count).by(1)
      end
      
      it "shows correct flash message on create" do
        post :create, { financial_provider: valid_attributes.merge(alternative_0: alternative_0) }, session: valid_session
        expect(flash[:success]).to be_present
      end
    end
    
    context "with attributes" do
      let(:financial_provider) { assigns(:financial_provider) }

      before do
        post :create, {financial_provider: valid_attributes.merge(alternative_0: alternative_0)}, session: valid_session
      end

      it "assigns a newly created financial provider as @financial_provider" do
        expect(financial_provider).to be_a(FinancialProvider)
        expect(financial_provider).to be_persisted
      end
      
      it "assigns a newly created financial alternative as a part of @financial_provider.alternatives" do
        expect(financial_provider.alternatives.first).to be_a(FinancialAlternative)
        expect(financial_provider.alternatives.first).to be_persisted
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
        expect(financial_provider.state).to eq "IL"
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
          provider_type: "Alternative",
          web_address: "www.newzokuvault.com",
          street_address: "Street New",
          city: "City New",
          state: "AL",
          zip: 66666,
          phone_number: "444-444-4444",
          fax_number: "555-555-5555",
          primary_contact_id: contacts.second.id,
          share_with_contact_ids: contacts.first(2).map(&:id),
          user_id: user.id
        }
      end
  
      let(:new_alternative_attributes) do 
        {
          alternative_type: "Seed",
          name: "Investment Name New",
          account_owner_ids: [contacts.second.id],
          commitment: "199.99",
          total_calls: "199.99",
          total_distributions: "199.99",
          current_value: "199.99",
          primary_contact_id: contacts.second.id,
          notes: "Notes New"
        }
      end
      
      let(:financial_provider) { assigns(:financial_provider) }
      
      before do
        financial_provider = FinancialProvider.create! valid_attributes
        AccountPolicyOwner
        put :update, { id: financial_provider.to_param, financial_provider: new_provider_attributes.merge(alternative_0: new_alternative_attributes) }, session: valid_session
        financial_alternative = financial_provider.alternatives.first
        financial_alternative.account_owner_ids = (AccountPolicyOwner.create contact_id: contacts.second.id, contactable_id: financial_alternative.id,
                                                                         contactable_type: financial_alternative.class).id
      end

      it "shows correct flash message on update" do
        expect(flash[:success]).to be_present
      end

      it "assigns the requested financial provider as @financial_provider" do
        expect(assigns(:financial_provider)).to eq(financial_provider)
      end
      
      it "assigns the requested financial alternative type" do
        expect(assigns(:financial_provider).alternatives.first.alternative_type).to eq "Seed"
      end
      
      it "assigns the requested financial alternative owner" do
        account_owner_id = AccountPolicyOwner.find_by(contactable_id: assigns(:financial_provider).alternatives.first.id).contact_id
        expect(account_owner_id).to eq contacts.second.id
      end
      
      it "assigns the requested financial alternative commitment" do
        expect(assigns(:financial_provider).alternatives.first.commitment.to_f).to eq 199.99
      end
      
      it "assigns the requested financial alternative total calls" do
        expect(assigns(:financial_provider).alternatives.first.total_calls.to_f).to eq 199.99
      end
      
      it "assigns the requested financial alternative total distributions" do
        expect(assigns(:financial_provider).alternatives.first.total_distributions.to_f).to eq 199.99
      end
      
      it "assigns the requested financial alternative current value" do
        expect(assigns(:financial_provider).alternatives.first.current_value.to_f).to eq 199.99
      end
      
      it "assigns the requested financial alternative primary contact" do
        expect(assigns(:financial_provider).alternatives.first.primary_contact).to eq contacts.second
      end
      
      it "assigns the requested financial alternative notes" do
        expect(assigns(:financial_provider).alternatives.first.notes).to eq "Notes New"
      end

      it "redirects to the financial_provider" do
        expect(response).to redirect_to(show_alternative_url(financial_provider))
      end
    end
  end
  
  describe "DELETE #destroy" do
    it "destroys the requested financial provider and redirect to main financial information page" do
      financial_provider = FinancialProvider.create! valid_attributes
      expect { delete :destroy_provider, { id: financial_provider.to_param }, session: valid_session }
        .to change(FinancialProvider, :count).by(-1)
      expect(response).to redirect_to financial_information_path
    end
    
    it "destroys the requested financial alternative and redirect to previous page" do
      financial_alternative = FinancialAlternative.create! alternative_0
      financial_provider = FinancialProvider.create! valid_attributes
      financial_provider.alternatives << financial_alternative
      expect { delete :destroy, { id: financial_alternative.to_param }, session: valid_session }
        .to change(financial_provider.alternatives, :count).by(-1)
      expect(response).to redirect_to financial_information_path
    end
    
    it "shows correct flash message on destroy provider" do
      financial_alternative = FinancialAlternative.create! alternative_0
      financial_provider = FinancialProvider.create! valid_attributes
      financial_provider.alternatives << financial_alternative
      delete :destroy_provider, { id: financial_provider.to_param }, session: valid_session
      expect(flash[:notice]).to be_present
    end
    
    it "shows correct flash message on destroy alternative" do
      financial_alternative = FinancialAlternative.create! alternative_0
      financial_provider = FinancialProvider.create! valid_attributes
      financial_provider.alternatives << financial_alternative
      delete :destroy, { id: financial_alternative.to_param }, session: valid_session
      expect(flash[:notice]).to be_present
    end
  end
end
