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
      policy_holder_id: contacts.first.id,
      coverage_amount: Faker::Commerce.price,
      broker_or_primary_contact_id: contacts[2].id,
      notes: Faker::Lorem.sentences(1).to_s,
    }
  end

  let(:valid_attributes) do
    {
      category: 'Insurance',
      group: 'property',
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
  # PropertiesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all property_and_casualties as @property_and_casualties" do
      post :create, { property_and_casualty: valid_attributes}, session: valid_session
      property_and_casualty = assigns(:insurance_card)
      get :index, params: {}, session: valid_session
      expect(assigns(:property_and_casualties)).to eq([property_and_casualty])
    end
  end

  xdescribe "GET #show" do
    it "assigns the requested property_and_casualty as @property_and_casualty" do
      property_and_casualty = PropertyAndCasualty.create! valid_attributes
      get :show, params: {id: property_and_casualty.to_param}, session: valid_session
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

  xdescribe "GET #edit" do
    it "assigns the requested property_and_casualty as @property_and_casualty" do
      property_and_casualty = PropertyAndCasualty.create! valid_attributes
      get :edit, params: {id: property_and_casualty.to_param}, session: valid_session
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
        expect(response).to redirect_to(insurance_path)
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

  xdescribe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested property_and_casualty" do
        property_and_casualty = PropertyAndCasualty.create! valid_attributes
        put :update, params: {id: property_and_casualty.to_param, property_and_casualty: new_attributes}, session: valid_session
        property_and_casualty.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested property_and_casualty as @property_and_casualty" do
        property_and_casualty = PropertyAndCasualty.create! valid_attributes
        put :update, params: {id: property_and_casualty.to_param, property_and_casualty: valid_attributes}, session: valid_session
        expect(assigns(:property_and_casualty)).to eq(property_and_casualty)
      end

      it "redirects to the property_and_casualty" do
        property_and_casualty = PropertyAndCasualty.create! valid_attributes
        put :update, params: {id: property_and_casualty.to_param, property_and_casualty: valid_attributes}, session: valid_session
        expect(response).to redirect_to(property_and_casualty)
      end
    end

    context "with invalid params" do
      it "assigns the property_and_casualty as @property_and_casualty" do
        property_and_casualty = PropertyAndCasualty.create! valid_attributes
        put :update, params: {id: property_and_casualty.to_param, property_and_casualty: invalid_attributes}, session: valid_session
        expect(assigns(:property_and_casualty)).to eq(property_and_casualty)
      end

      it "re-renders the 'edit' template" do
        property_and_casualty = PropertyAndCasualty.create! valid_attributes
        put :update, params: {id: property_and_casualty.to_param, property_and_casualty: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  xdescribe "DELETE #destroy" do
    it "destroys the requested property_and_casualty" do
      property_and_casualty = PropertyAndCasualty.create! valid_attributes
      expect {
        delete :destroy, params: {id: property_and_casualty.to_param}, session: valid_session
      }.to change(PropertyAndCasualty, :count).by(-1)
    end

    it "redirects to the property_and_casualties list" do
      property_and_casualty = PropertyAndCasualty.create! valid_attributes
      delete :destroy, params: {id: property_and_casualty.to_param}, session: valid_session
      expect(response).to redirect_to(property_and_casualties_url)
    end
  end
end
