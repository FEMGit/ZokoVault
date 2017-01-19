require 'rails_helper'

RSpec.describe HealthsController, type: :controller do

  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:document) { create(:document) }
  let(:user) { create :user }

  before { sign_in user }

  let(:valid_session) { {} }

  let(:policy_attributes) do
    {
      policy_type: HealthPolicy.policy_types.keys.sample,
      policy_number: Faker::Code.imei,
      policy_holder_id: contacts.first.id,
      group_number: Faker::Code.imei,
      broker_or_primary_contact_id: contacts[2].id,
      notes: Faker::Lorem.sentences(1).to_s,
    }
  end

  let(:valid_attributes) do
    {
      category: Category.fetch('insurance'),
      group: 'health',
      name: Faker::Company.name,
      webaddress: Faker::Internet.url,
      phone: Faker::PhoneNumber.phone_number,
      fax: Faker::PhoneNumber.phone_number,
      street_address_1: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      user_id: user.id,
      contact_id: contacts.sample.id,
      share_with_ids: contacts.last(2).map(&:id).map(&:to_s),
      policy_attributes: policy_attributes
    }
  end

  let(:invalid_attributes) do
    { user_id: user.id }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # HealthsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all healths as @healths" do
      post :create, { health: valid_attributes}, session: valid_session
      health = assigns(:insurance_card)
      get :index, params: {}, session: valid_session
      expect(assigns(:healths)).to eq([health])
    end
  end

  describe "GET #show" do
    before :each do
      post :create, { health: valid_attributes}, session: valid_session
      @insurance_card = assigns(:insurance_card)
    end

    it "assigns the requested health as @insurance_card" do
      get :show, {id: @insurance_card.to_param}, session: valid_session
      expect(assigns(:insurance_card)).to eq(@insurance_card)
    end

    it "assigns a group documents as @group_documents" do
      document = create(:document, user_id: user.id, category: "Insurance", group: "Health", vendor_id: @insurance_card.id)
      get :show, {id: @insurance_card.to_param}, session: valid_session
      expect(assigns(:group_documents)).to eq([document])
    end
  end

  describe "GET #new" do
    it "assigns a new health as @insurance_card" do
      get :new, {}, session: valid_session
      expect(assigns(:insurance_card)).to be_a_new(Health)
    end

    it "builds a health policy for @insurance_card" do
      get :new, {}, session: valid_session
      expect(assigns(:insurance_card).policy.first).to be_a_new(HealthPolicy)
    end
  end

  describe "GET #edit" do
    it "assigns the requested health as @insurance_card" do
      post :create, { health: valid_attributes}, session: valid_session
      insurance_card = assigns(:insurance_card)
      get :edit, {id: insurance_card.to_param}, session: valid_session
      expect(assigns(:insurance_card)).to eq(insurance_card)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:health) { assigns(:health) }

      it "creates a new Health" do
        expect {
          post :create, { health: valid_attributes}, session: valid_session
        }.to change(Health, :count).by(1)
      end
      
      it "shows correct flash message on create" do
        post :create, { health: valid_attributes}, session: valid_session
        expect(flash[:success]).to be_present
      end

      it "assigns a newly created health as @insurance_card" do
        post :create, { health: valid_attributes}, session: valid_session
        health = assigns(:insurance_card)

        expect(health).to be_a(Health)
        expect(health).to be_persisted

        valid_attributes.except(:policy_attributes).each do |attribute, value|
          expect(health.send(attribute)).to eq value
        end

        policy = health.policy.first
        valid_attributes[:policy_attributes].each do |attribute, value|
          expect(policy.send(attribute)).to eq value
        end
      end

      it "redirects to the created health" do
        post :create, { health: valid_attributes}, session: valid_session
        expect(response).to redirect_to(insurance_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved health as @health" do
        post :create, { health: invalid_attributes}, session: valid_session
        expect(assigns(:insurance_card)).to be_a_new(Health)
      end

      it "re-renders the 'new' template" do
        post :create, { health: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  xdescribe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested health" do
        health = Health.create! valid_attributes
        put :update, params: {id: health.to_param, health: new_attributes}, session: valid_session
        health.reload
        skip("Add assertions for updated state")
      end
      
      it "shows correct flash message on update" do
        health = Health.create! valid_attributes
        put :update, params: {id: health.to_param, health: valid_attributes}, session: valid_session
        expect(flash[:success]).to be_present
      end

      it "assigns the requested health as @health" do
        health = Health.create! valid_attributes
        put :update, params: {id: health.to_param, health: valid_attributes}, session: valid_session
        expect(assigns(:health)).to eq(health)
      end

      it "redirects to the health" do
        health = Health.create! valid_attributes
        put :update, params: {id: health.to_param, health: valid_attributes}, session: valid_session
        expect(response).to redirect_to(health)
      end
    end

    context "with invalid params" do
      it "assigns the health as @health" do
        health = Health.create! valid_attributes
        put :update, params: {id: health.to_param, health: invalid_attributes}, session: valid_session
        expect(assigns(:health)).to eq(health)
      end

      it "re-renders the 'edit' template" do
        health = Health.create! valid_attributes
        put :update, params: {id: health.to_param, health: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  xdescribe "DELETE #destroy" do
    it "destroys the requested health" do
      health = Health.create! valid_attributes
      expect {
        delete :destroy, params: {id: health.to_param}, session: valid_session
      }.to change(Health, :count).by(-1)
    end

    it "redirects to the healths list" do
      health = Health.create! valid_attributes
      delete :destroy, params: {id: health.to_param}, session: valid_session
      expect(response).to redirect_to(healths_url)
    end
    
    it "shows correct flash message on destroy" do
      health = Health.create! valid_attributes
      delete :destroy, params: {id: health.to_param}, session: valid_session
      expect(flash[:notice]).to be_present
    end
  end
end