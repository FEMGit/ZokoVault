require 'rails_helper'

RSpec.describe PropertyAndCasualtiesController, type: :controller do

  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:document) { create(:document) }
  let(:user) { create :user }

  before { sign_in user }

  let(:valid_session) { {} }

  let(:policy_attributes) do
    {
      policy_type: PropertyAndCasualtyPolicy.policy_types.keys.sample,
      policy_number: Faker::Code.imei,
      insured_property: "foo",
      coverage_amount: Faker::Commerce.price,
      broker_or_primary_contact_id: contacts[2].id,
      notes: Faker::Lorem.sentences(1).to_s,
    }
  end

  let(:valid_attributes) do
    {
      category: Category.fetch('insurance'),
      group: 'property',
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
  # PropertiesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  # Removed #index rspec - because there is no index action for property

  describe "GET #show" do
    it "assigns the requested property_and_casualty as @property_and_casualty" do
      post :create, { property_and_casualty: valid_attributes}, valid_session
      property_and_casualty = assigns(:insurance_card)
      get :show, {id: property_and_casualty.to_param}, valid_session
      expect(assigns(:property_and_casualty)).to eq(property_and_casualty)
    end
  end

  describe "GET #new" do
    it "assigns a new property_and_casualty as @property_and_casualty" do
      get :new, {}, session: valid_session
      property_and_casualty = assigns(:insurance_card)
      expect(property_and_casualty).to be_a_new(PropertyAndCasualty)
      expect(property_and_casualty.policy.first).to be_a_new(PropertyAndCasualtyPolicy)
    end
  end

  describe "GET #edit" do
    it "assigns the requested property_and_casualty as @property_and_casualty" do
      post :create, { property_and_casualty: valid_attributes}, valid_session
      property_and_casualty = assigns(:insurance_card)
      get :edit, {id: property_and_casualty.to_param}, valid_session
      expect(assigns(:property_and_casualty)).to eq(property_and_casualty)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:property_and_casualty) { assigns(:property_and_casualty) }

      it "creates a new PropertyAndCasualty" do
        expect {
          post :create, { property_and_casualty: valid_attributes }, session: valid_session
        }.to change(PropertyAndCasualty, :count).by(1)
      end

      it "assigns a newly created property_and_casualty as @property_and_casualty" do
        post :create, { property_and_casualty: valid_attributes}, session: valid_session
        property_and_casualty = assigns(:insurance_card)

        expect(property_and_casualty).to be_a(PropertyAndCasualty)
        expect(property_and_casualty).to be_persisted

        valid_attributes.except(:policy_attributes).each do |attribute, value|
          expect(property_and_casualty.send(attribute)).to eq value
        end

        policy = property_and_casualty.policy.first
        valid_attributes[:policy_attributes].each do |attribute, value|
          expect(policy.send(attribute)).to eq value
        end
      end

      it "redirects to the created property_and_casualty" do
        post :create, { property_and_casualty: valid_attributes}, session: valid_session
        property = assigns(:insurance_card)
        expect(response).to redirect_to(property_path(property))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved property_and_casualty as @property_and_casualty" do
        post :create, { property_and_casualty: invalid_attributes}, session: valid_session
        expect(assigns(:insurance_card)).to be_a_new(PropertyAndCasualty)
      end

      it "re-renders the 'new' template" do
        post :create, { property_and_casualty: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_name) { Faker::Company.name }
      let(:new_valid_attributes) { valid_attributes.merge({ name: new_name }) }

      it "updates the requested property_and_casualty" do
        post :create, { property_and_casualty: valid_attributes}, valid_session
        property_and_casualty = assigns(:insurance_card)
        put :update, {
          id: property_and_casualty.to_param, property_and_casualty: new_valid_attributes
        }, valid_session
        property_and_casualty.reload
        expect(property_and_casualty.name).to eq(new_name)
      end

      it "assigns the requested property_and_casualty as @property_and_casualty" do
        post :create, { property_and_casualty: valid_attributes}, valid_session
        property_and_casualty = assigns(:insurance_card)
        put :update, {
          id: property_and_casualty.to_param, property_and_casualty: new_valid_attributes
        }, valid_session
        expect(assigns(:property_and_casualty)).to eq(property_and_casualty)
      end

      it "redirects to the property_and_casualty" do
        post :create, { property_and_casualty: valid_attributes}, valid_session
        property_and_casualty = assigns(:insurance_card)
        put :update, {
          id: property_and_casualty.to_param, property_and_casualty: new_valid_attributes
        }, valid_session
        expect(response).to redirect_to(:property)
      end
    end

    context "with invalid params" do
      let(:new_invalid_attributes) { valid_attributes.merge({ name: "" }) }

      it "assigns the property_and_casualty as @property_and_casualty" do
        post :create, { property_and_casualty: valid_attributes}, valid_session
        property_and_casualty = assigns(:insurance_card)
        put :update, {
          id: property_and_casualty.to_param, property_and_casualty: new_invalid_attributes
        }, valid_session
        expect(assigns(:property_and_casualty)).to eq(property_and_casualty)
      end

      it "re-renders the 'edit' template" do
        post :create, { property_and_casualty: valid_attributes}, valid_session
        property_and_casualty = assigns(:insurance_card)
        put :update, {
          id: property_and_casualty.to_param, property_and_casualty: new_invalid_attributes
        }, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested property_and_casualty_policy" do
      post :create, { property_and_casualty: valid_attributes}, valid_session
      property_and_casualty = assigns(:insurance_card)
      policy = property_and_casualty.policy.first
      expect {
        delete :destroy, {id: policy.to_param}, valid_session
      }.to change(PropertyAndCasualtyPolicy, :count).by(-1)
    end

    it "redirects to the property_and_casualties list" do
      post :create, { property_and_casualty: valid_attributes}, valid_session
      property_and_casualty = assigns(:insurance_card)
      policy = property_and_casualty.policy.first
      delete :destroy, {id: policy.to_param}, valid_session
      expect(response).to redirect_to insurance_path
    end
  end
end