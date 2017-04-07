require 'rails_helper'

RSpec.describe PowerOfAttorneysController, type: :controller do

  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:document) { create(:document) }
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      user_id: user.id,
      powers: Hash[PowerOfAttorney::POWERS.sample(3).zip([true,true,true])],
      agent_ids: contacts[0].id,
      share_with_contact_ids: contacts.map(&:id),
      document_id: document.id
    }
  end

  let(:invalid_attributes) do
    { id: "", user_id: user.id }
  end

  before { sign_in user }

  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all power_of_attorneys as @power_of_attorneys" do
      power_of_attorney = create(:power_of_attorney, user_id: user.id)
      get :index, {}, valid_session
      expect(assigns(:power_of_attorneys)).to eq([power_of_attorney])
    end
  end

  xdescribe "GET #show" do
    # No view with this action, raises ActionView::MissingTemplate error
    it "assigns the requested power_of_attorney as @power_of_attorney" do
      power_of_attorney = create(:power_of_attorney, user_id: user.id)
      get :show, { id: power_of_attorney.to_param }, valid_session
      expect(assigns(:power_of_attorney)).to eq(power_of_attorney)
    end
  end

  describe "GET #new" do
    it "assigns a new vault_entry as @vault_entry" do
      get :new, {}, session: valid_session
      expect(assigns(:vault_entry)).to be_a_new(PowerOfAttorney)
    end
  end

  describe "GET #edit" do
    it "assigns the requested power_of_attorney as @vault_entries" do
      power_of_attorney = create(:power_of_attorney, user_id: user.id)
      get :new, { id: power_of_attorney.to_param }, valid_session
      expect(assigns(:vault_entries).first).to eq(power_of_attorney)
    end
  end

  describe "POST #create" do
    context "with invalid params" do
      it "redirects to new" do
        post :create, { vault_entry_0: invalid_attributes }, session: valid_session
        expect(response).to redirect_to power_of_attorneys_path
      end
    end

    context "with valid params" do
      it "creates a new PowerOfAttorney" do
        expect { post :create, { vault_entry_0: valid_attributes.merge(:id => "") }, session: valid_session }
          .to change(PowerOfAttorney, :count).by(1)
      end

      context "with attributes" do
        let(:vault_entry) { assigns(:new_vault_entries) }

        before do
          post :create, {vault_entry_0: valid_attributes.merge(:id => "")}, session: valid_session
        end

        it "assigns a newly created vault_entry as @vault_entry" do
          expect(vault_entry).to be_a(PowerOfAttorney)
          expect(vault_entry).to be_persisted
        end

        it "assigns agents" do
          expect(vault_entry.agents.first).to eq contacts[0]
        end

        it "assigns shares" do
          expect(vault_entry.share_with_contacts.size).to eq contacts.size
        end

        it "assigns document" do
          expect(vault_entry.document).to eq document
        end

        it "assigns user" do
          expect(vault_entry.user).to eq user
        end
      end

      it "redirects to the created vault_entry" do
        post :create, { vault_entry_0: valid_attributes.merge(:id => "") }, session: valid_session
        expect(response).to redirect_to(power_of_attorneys_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved vault_entry as @vault_entry" do
        post :create, { vault_entry_0: invalid_attributes }, session: valid_session
        expect(assigns(:new_vault_entries)).to be_a(PowerOfAttorney)
      end

      it "re-renders the 'new' template" do
        post :create, { vault_entry_0: invalid_attributes }, session: valid_session
        expect(response).to redirect_to(power_of_attorneys_path)
      end
    end
  end

  xdescribe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        skip("Add a hash of attributes valid for your model")
      end

      it "updates the requested vault_entry" do
        vault_entry = PowerOfAttorney.create! valid_attributes
        put :update, { id: vault_entry.to_param, power_of_attorney: new_attributes }, session: valid_session
        vault_entry.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested vault_entry as @vault_entry" do
        vault_entry = PowerOfAttorney.create! valid_attributes
        put :update, { id: vault_entry.to_param, power_of_attorney: valid_attributes }, session: valid_session
        expect(assigns(:vault_entry)).to eq(vault_entry)
      end

      it "redirects to the vault_entry" do
        vault_entry = PowerOfAttorney.create! valid_attributes
        put :update, { id: vault_entry.to_param, power_of_attorney: valid_attributes }, session: valid_session
        expect(response).to redirect_to(vault_entry)
      end
    end

    context "with invalid params" do
      it "assigns the vault_entry as @vault_entry" do
        vault_entry = PowerOfAttorney.create! valid_attributes
        put :update, { id: vault_entry.to_param, power_of_attorney: invalid_attributes }, session: valid_session
        expect(assigns(:vault_entry)).to eq(vault_entry)
      end

      it "re-renders the 'edit' template" do
        vault_entry = PowerOfAttorney.create! valid_attributes
        put :update, { id: vault_entry.to_param, power_of_attorney: invalid_attributes }, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested power_of_attorney" do
      power_of_attorney = create(:power_of_attorney, user_id: user.id)
      expect {
        delete :destroy, { id: power_of_attorney.to_param }, valid_session
      }.to change(PowerOfAttorney, :count).by(-1)
    end

    it "redirects to the vault_entries list" do
      power_of_attorney = create(:power_of_attorney, user_id: user.id)
      delete :destroy, { id: power_of_attorney.to_param }, valid_session
      expect(response).to redirect_to power_of_attorneys_path
    end
  end

end
