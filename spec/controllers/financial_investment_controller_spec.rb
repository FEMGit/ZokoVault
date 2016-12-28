require 'rails_helper'

RSpec.describe FinancialInvestmentController, type: :controller do

  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Investment Name",
      web_address: "www.zokuvault.com",
      investment_type: "Private Company Stock",
      notes: "Notes",
      value: "99.99",
      owner_id: contacts.first.id,
      address: "Address",
      city: "City",
      state: "State",
      zip: 55555,
      phone_number: "777-777-7777",
      primary_contact_id: contacts.first.id,
      share_with_contact_ids: contacts.map(&:id),
      user_id: user.id
    }
  end
  
  let(:invalid_attributes) do
    { id: "", user_id: user.id }
  end

  before { sign_in user }

  let(:valid_session) { {} }
  
  describe "GET #show" do
    it "assigns the requested financial investment @financial_investment" do
      financial_investment = FinancialInvestment.create! valid_attributes
      get :show, { id: financial_investment.to_param }, session: valid_session
      expect(assigns(:financial_investment)).to eq(financial_investment)
    end
  end
  
  describe "GET #new" do
    it "assigns a new financial investment as @financial_investment" do
      get :new, {}, session: valid_session
      expect(assigns(:financial_investment)).to be_a_new(FinancialInvestment)
    end
  end

  describe "GET #edit" do
    it "assigns the requested financial investment as @financial_investment" do
      financial_investment = FinancialInvestment.create! valid_attributes
      get :edit, { id: financial_investment.to_param }, session: valid_session
      expect(assigns(:financial_investment)).to eq(financial_investment)
    end
  end
  
  describe "POST #create" do
    context "with valid params" do
      it "creates a new financial investment" do 
        expect { post :create, { financial_investment: valid_attributes }, session: valid_session }
          .to change(FinancialInvestment, :count).by(1)
      end
      
      it "shows correct flash message on create" do
        post :create, { financial_investment: valid_attributes }, session: valid_session
        expect(flash[:success]).to be_present
      end
    end
    
    context "with valid attributes" do
      let(:financial_investment) { assigns(:financial_investment) }

      before do
        post :create, { financial_investment: valid_attributes }, session: valid_session
      end

      it "assigns a newly created financial investment as @financial_investment" do
        expect(financial_investment).to be_a(FinancialInvestment)
        expect(financial_investment).to be_persisted
      end
      
      it "assigns name" do
        expect(financial_investment.name).to eq "Investment Name"
      end
      
      it "assigns web_address" do
        expect(financial_investment.web_address).to eq "www.zokuvault.com"
      end
      
      it "assigns investment_type" do
        expect(financial_investment.investment_type).to eq "Private Company Stock"
      end
      
      it "assigns notes" do
        expect(financial_investment.notes).to eq "Notes"
      end
      
      it "assigns value" do
        expect(financial_investment.value.to_f).to eq 99.99
      end
      
      it "assigns owner" do
        expect(financial_investment.owner).to eq contacts.first
      end
      
      it "assigns address" do
        expect(financial_investment.address).to eq "Address"
      end
      
      it "assigns city" do
        expect(financial_investment.city).to eq "City"
      end
      
      it "assigns state" do
        expect(financial_investment.state).to eq "State"
      end
      
      it "assigns zip code" do
        expect(financial_investment.zip).to eq 55555
      end
      
      it "assigns phone_number" do
        expect(financial_investment.phone_number).to eq "777-777-7777"
      end
      
      it "assigns primary_contact" do
        expect(financial_investment.primary_contact).to eq contacts.first
      end
      
      it "assigns share_with-contacts" do
        expect(financial_investment.share_with_contacts).to eq contacts
      end
    end
    
    context "with invalid params" do
      it "assigns a newly created but unsaved financial investment as @financial_investment" do
        post :create, { financial_investment: invalid_attributes }, session: valid_session
        expect(assigns(:financial_investment)).to be_a(FinancialInvestment)
      end

      it "re-renders the 'new' template" do
        post :create, { financial_investment: invalid_attributes }, session: valid_session
        expect(response).to render_template :new
      end
    end
  end
 
  describe "PUT #update" do
    context "with valid params" do
      let(:new_valid_attributes) do
        {
          name: "Investment Name New",
          web_address: "www.newzokuvault.com",
          investment_type: "IOU",
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
      
      let(:financial_investment) { assigns(:financial_investment) }
      
      before do
        financial_investment = FinancialInvestment.create! valid_attributes
        put :update, { id: financial_investment.to_param, financial_investment: new_valid_attributes }, session: valid_session
      end

      it "shows correct flash message on update" do
        expect(flash[:success]).to be_present
      end

      it "assigns the requested financial investment as @financial_investment" do
        expect(assigns(:financial_investment)).to eq(financial_investment)
      end
      
      it "assigns name" do
        expect(financial_investment.name).to eq "Investment Name New"
      end
      
      it "assigns web_address" do
        expect(financial_investment.web_address).to eq "www.newzokuvault.com"
      end
      
      it "assigns investment_type" do
        expect(financial_investment.investment_type).to eq "IOU"
      end
      
      it "assigns notes" do
        expect(financial_investment.notes).to eq "Notes New"
      end
      
      it "assigns value" do
        expect(financial_investment.value.to_f).to eq 100
      end
      
      it "assigns owner" do
        expect(financial_investment.owner).to eq contacts.second
      end
      
      it "assigns address" do
        expect(financial_investment.address).to eq "Address New"
      end
      
      it "assigns city" do
        expect(financial_investment.city).to eq "City New"
      end
      
      it "assigns state" do
        expect(financial_investment.state).to eq "State New"
      end
      
      it "assigns zip code" do
        expect(financial_investment.zip).to eq 44444
      end
      
      it "assigns phone_number" do
        expect(financial_investment.phone_number).to eq "888-888-8888"
      end
      
      it "assigns primary_contact" do
        expect(financial_investment.primary_contact).to eq contacts.second
      end
      
      it "assigns share_with-contacts" do
        expect(financial_investment.share_with_contacts).to eq contacts.first(2)
      end
    end
  end
  
  describe "DELETE #destroy" do
    it "destroys the requested financial investment and redirect to main financial information page" do
      financial_investment = FinancialInvestment.create! valid_attributes
      expect { delete :destroy, { id: financial_investment.to_param }, session: valid_session }
        .to change(FinancialInvestment, :count).by(-1)
      expect(response).to redirect_to financial_information_path
    end

    it "shows correct flash message on destroy provider" do
      financial_investment = FinancialInvestment.create! valid_attributes
      delete :destroy, { id: financial_investment.to_param }, session: valid_session
      expect(flash[:notice]).to be_present
    end
  end
end
