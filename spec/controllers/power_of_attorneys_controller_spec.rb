require 'rails_helper'

RSpec.describe PowerOfAttorneysController, type: :controller do

  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:document) { create(:document) }
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      user_id: user.id,
      powers: Hash[PowerOfAttorney::POWERS.sample(3).zip([true,true,true])],
      agent_ids: contacts.map(&:id),
      share_ids: contacts.map(&:id),
      document_id: document.id
    }
  end

  let(:invalid_attributes) do
    { user_id: nil }
  end

  before { sign_in user }

  let(:valid_session) { {} }

  xdescribe "GET #index" do
    it "assigns all vault_entries as @vault_entries" do
      vault_entry = PowerOfAttorney.create! valid_attributes
      get :index, {}, session: valid_session
      expect(assigns(:vault_entries)).to eq([vault_entry])
    end
  end

  xdescribe "GET #show" do
    it "assigns the requested vault_entry as @vault_entry" do
      vault_entry = PowerOfAttorney.create! valid_attributes
      get :show, { id: vault_entry.to_param }, session: valid_session
      expect(assigns(:vault_entry)).to eq(vault_entry)
    end
  end

  describe "GET #new" do
    it "assigns a new vault_entry as @vault_entry" do
      get :new, {}, session: valid_session
      expect(assigns(:vault_entry)).to be_a_new(PowerOfAttorney)
    end
  end

  xdescribe "GET #edit" do
    it "assigns the requested vault_entry as @vault_entry" do
      vault_entry = PowerOfAttorney.create! valid_attributes
      get :edit, { id: vault_entry.to_param }, session: valid_session
      expect(assigns(:vault_entry)).to eq(vault_entry)
    end
  end

  describe "POST #create" do
    context "with invalid params" do
      it "redirects to new" do
        post :create, { power_of_attorney: invalid_attributes }, session: valid_session
        expect(response).to render_template(:new)
      end
    end

    context "with valid params" do
      it "creates a new PowerOfAttorney" do 
        post :create, { power_of_attorney: valid_attributes }, session: valid_session 
        expect { post :create, { power_of_attorney: valid_attributes }, session: valid_session }
          .to change(PowerOfAttorney, :count).by(1)
      end

      context "with attributes" do
        let(:vault_entry) { assigns(:vault_entry) }

        before do
          post :create, power_of_attorney: valid_attributes, session: valid_session
        end

        it "assigns a newly created vault_entry as @vault_entry" do
          expect(vault_entry).to be_a(PowerOfAttorney)
          expect(vault_entry).to be_persisted
        end

        it "assigns agents" do
          expect(vault_entry.agents).to eq contacts
        end

        it "assigns shares" do
          expect(vault_entry.shares.size).to eq contacts.size
        end

        it "assigns document" do
          expect(vault_entry.document).to eq document
        end

        it "assigns user" do
          expect(vault_entry.user).to eq user
        end
      end

      it "redirects to the created vault_entry" do
        post :create, { power_of_attorney: valid_attributes }, session: valid_session
        expect(response).to redirect_to(estate_planning_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved vault_entry as @vault_entry" do
        post :create, { power_of_attorney: invalid_attributes }, session: valid_session
        expect(assigns(:vault_entry)).to be_a_new(PowerOfAttorney)
      end

      it "re-renders the 'new' template" do
        post :create, { power_of_attorney: invalid_attributes }, session: valid_session
        expect(response).to render_template("new")
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

  xdescribe "DELETE #destroy" do
    it "destroys the requested vault_entry" do
      vault_entry = PowerOfAttorney.create! valid_attributes
      expect { delete :destroy, { id: vault_entry.to_param }, session: valid_session }
        .to change(PowerOfAttorney, :count).by(-1)
    end

    it "redirects to the vault_entries list" do
      vault_entry = PowerOfAttorney.create! valid_attributes
      delete :destroy, { id: vault_entry.to_param }, session: valid_session
      expect(response).to redirect_to(vault_entries_url)
    end
  end

end