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
      policy_holder_id: contacts.first.id,
      coverage_amount: Faker::Commerce.price,
      policy_number: Faker::Code.imei,
      broker_or_primary_contact_id: contacts[2].id,
      notes: Faker::Lorem.sentences(1).to_s,
    }
  end

  let(:valid_attributes) do
    {
      category: 'Insurance',
      group: 'life',
      name: Faker::Company.name,
      webaddress: Faker::Internet.url,
      phone: Faker::PhoneNumber.phone_number,
      fax: Faker::PhoneNumber.phone_number,
      street_address_1: Faker::Address.street_address,
      street_address_2: Faker::Address.secondary_address,
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

  describe "GET #index" do
    it "assigns all life_and_disabilities as @life_and_disabilities" do
      life = LifeAndDisability.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:life_and_disabilities)).to eq([life])
    end
  end

  xdescribe "GET #show" do
    it "assigns the requested life as @life" do
      life = LifeAndDisability.create! valid_attributes
      get :show, params: {id: life.to_param}, session: valid_session
      expect(assigns(:life)).to eq(life)
    end
  end

  describe "GET #new" do
    it "assigns a new life as @life_and_disability" do
      get :new, params: {}, session: valid_session
      life_and_disability = assigns(:life_and_disability)
      expect(life_and_disability).to be_a_new(LifeAndDisability)
      expect(life_and_disability.policy).to be_a_new(LifeAndDisabilityPolicy)
    end
  end

  xdescribe "GET #edit" do
    it "assigns the requested life as @life" do
      life = LifeAndDisability.create! valid_attributes
      get :edit, params: {id: life.to_param}, session: valid_session
      expect(assigns(:life)).to eq(life)
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
        life_and_disability = assigns(:life_and_disability)

        expect(life_and_disability).to be_a(LifeAndDisability)
        expect(life_and_disability).to be_persisted

        valid_attributes.except(:policy_attributes).each do |attribute, value|
          expect(life_and_disability.send(attribute)).to eq value
        end

        policy = life_and_disability.policy
        valid_attributes[:policy_attributes].each do |attribute, value|
          expect(policy.send(attribute)).to eq value
        end
      end

      it "redirects to the created life" do
        post :create, { life_and_disability: valid_attributes}, session: valid_session
        expect(response).to redirect_to(insurance_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved life as @life" do
        post :create, { life_and_disability: invalid_attributes}, session: valid_session
        expect(assigns(:life_and_disability)).to be_a_new(LifeAndDisability)
      end

      it "re-renders the 'new' template" do
        post :create, { life_and_disability: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  xdescribe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested life" do
        life = LifeAndDisability.create! valid_attributes
        put :update, params: {id: life.to_param, life: new_attributes}, session: valid_session
        life.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested life as @life" do
        life = LifeAndDisability.create! valid_attributes
        put :update, params: {id: life.to_param, life: valid_attributes}, session: valid_session
        expect(assigns(:life)).to eq(life)
      end

      it "redirects to the life" do
        life = LifeAndDisability.create! valid_attributes
        put :update, params: {id: life.to_param, life: valid_attributes}, session: valid_session
        expect(response).to redirect_to(life)
      end
    end

    context "with invalid params" do
      it "assigns the life as @life" do
        life = LifeAndDisability.create! valid_attributes
        put :update, params: {id: life.to_param, life: invalid_attributes}, session: valid_session
        expect(assigns(:life)).to eq(life)
      end

      it "re-renders the 'edit' template" do
        life = LifeAndDisability.create! valid_attributes
        put :update, params: {id: life.to_param, life: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  xdescribe "DELETE #destroy" do
    it "destroys the requested life" do
      life = LifeAndDisability.create! valid_attributes
      expect {
        delete :destroy, params: {id: life.to_param}, session: valid_session
      }.to change(Life, :count).by(-1)
    end

    it "redirects to the lives list" do
      life = LifeAndDisability.create! valid_attributes
      delete :destroy, params: {id: life.to_param}, session: valid_session
      expect(response).to redirect_to(lives_url)
    end
  end

end
