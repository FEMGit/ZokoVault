require 'rails_helper'

RSpec.describe LifeAndDisabilitiesController, type: :controller do

  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:document) { create(:document) }
  let(:user) { create :user }

  before { sign_in user }

  let(:valid_session) { {} }

  let(:policy_attributes) do
    {
      policy_type: LifeAndDisabilityPolicy.policy_types.keys.sample,
      policy_holder_id: contacts.first.id.to_s + "_contact",
      coverage_amount: Faker::Commerce.price,
      policy_number: Faker::Code.imei,
      broker_or_primary_contact_id: contacts[2].id,
      notes: Faker::Lorem.sentences(1).to_s,
    }
  end

  let(:valid_attributes) do
    {
      category: Category.fetch('insurance'),
      group: 'life',
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
  # LivesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  # Removed #index rspec - because there is no index action for life

  describe "GET #show" do
    it "assigns the requested life_and_disability as @insurance_card" do
      post :create, { life_and_disability: valid_attributes }, session: valid_session
      life = assigns(:insurance_card)
      get :show, {id: life.to_param}, valid_session
      expect(assigns(:insurance_card)).to eq(life)
    end
  end

  describe "GET #new" do
    it "assigns a new life as @life_and_disability" do
      get :new, params: {}, session: valid_session
      life_and_disability = assigns(:insurance_card)
      expect(life_and_disability).to be_a_new(LifeAndDisability)
      expect(life_and_disability.policy.first).to be_a_new(LifeAndDisabilityPolicy)
    end
  end

  describe "GET #edit" do
    it "assigns the requested life as @life_and_disability" do
      post :create, { life_and_disability: valid_attributes }, session: valid_session
      life = assigns(:insurance_card)
      get :edit, { id: life.to_param }, valid_session
      expect(assigns(:insurance_card)).to eq(life)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:life_and_disability) { assigns(:life_and_disability) }

      it "creates a new Life" do
        expect {
          post :create, { life_and_disability: valid_attributes}, session: valid_session
        }.to change(LifeAndDisability, :count).by(1)
      end

      it "assigns a newly created life as @life_and_disability" do
        post :create, { life_and_disability: valid_attributes}, session: valid_session
        life_and_disability = assigns(:insurance_card)

        expect(life_and_disability).to be_a(LifeAndDisability)
        expect(life_and_disability).to be_persisted

        valid_attributes.except(:policy_attributes).each do |attribute, value|
          expect(life_and_disability.send(attribute)).to eq value
        end

        policy = life_and_disability.policy.first
        valid_attributes[:policy_attributes].except(:policy_holder_id).each do |attribute, value|
          expect(policy.send(attribute)).to eq value
        end
        
        expect(AccountPolicyOwner.find_by(contactable_id: policy.id).contact_id).to eq contacts.first.id
      end

      it "redirects to the created life" do
        post :create, { life_and_disability: valid_attributes}, session: valid_session
        life = assigns(:insurance_card)
        expect(response).to redirect_to(life_path(life))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved life as @life" do
        post :create, { life_and_disability: invalid_attributes}, session: valid_session
        expect(assigns(:insurance_card)).to be_a_new(LifeAndDisability)
      end

      it "re-renders the 'new' template" do
        post :create, { life_and_disability: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_name) { Faker::Company.name }
      let(:new_policy_attributes) do
        policy_attributes.merge({ coverage_amount: Faker::Commerce.price })
      end
      let(:new_attributes) {
        valid_attributes.merge({
          name: new_name,
          policy_attributes: new_policy_attributes })
      }

      it "updates the requested life" do
        post :create, { life_and_disability: valid_attributes}, valid_session
        life = assigns(:insurance_card)
        put :update, {id: life.to_param, life_and_disability: new_attributes}, valid_session
        life = assigns(:insurance_card)

        new_attributes.except(:policy_attributes).each do |attribute, value|
          expect(life.send(attribute)).to eq(value)
        end
      end

      it "assigns the requested life as @insurance_card" do
        post :create, { life_and_disability: valid_attributes}, valid_session
        life = assigns(:insurance_card)
        put :update, {id: life.to_param, life_and_disability: valid_attributes}, valid_session
        expect(assigns(:insurance_card)).to eq(life)
      end

      it "redirects to the life" do
        post :create, { life_and_disability: valid_attributes}, valid_session
        life = assigns(:insurance_card)
        put :update, {id: life.to_param, life_and_disability: valid_attributes}, valid_session
        expect(response).to redirect_to(life_path)
      end
    end

    context "with invalid params" do
      let(:invalid_name) { "" }
      let(:invalid_attributes) { valid_attributes.merge({ name: invalid_name }) }

      it "assigns the requested life as @insurance_card" do
        post :create, { life_and_disability: valid_attributes}, valid_session
        life = assigns(:insurance_card)
        put :update, {id: life.to_param, life_and_disability: invalid_attributes}, valid_session
        expect(assigns(:insurance_card)).to eq(life)
      end

      it "re-renders the 'edit' template" do
        post :create, { life_and_disability: valid_attributes}, valid_session
        life = assigns(:insurance_card)
        put :update, {id: life.to_param, life_and_disability: invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested life_and_disability_policy" do
      post :create, { life_and_disability: valid_attributes}, valid_session
      policy = assigns(:insurance_card).policy.first
      expect {
        delete :destroy, {id: policy.to_param}, valid_session
      }.to change(LifeAndDisabilityPolicy, :count).by(-1)
    end

    it "redirects to the lives list" do
      post :create, { life_and_disability: valid_attributes}, valid_session
      policy = assigns(:insurance_card).policy.first
      delete :destroy, {id: policy.to_param}, valid_session
      expect(response).to redirect_to insurance_path
    end
  end

end