require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe VaultEntriesController, type: :controller do

  let(:user) { create :user }

  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  before { sign_in user }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # VaultEntriesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all vault_entries as @vault_entries" do
      vault_entry = VaultEntry.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:vault_entries)).to eq([vault_entry])
    end
  end

  describe "GET #show" do
    it "assigns the requested vault_entry as @vault_entry" do
      vault_entry = VaultEntry.create! valid_attributes
      get :show, params: {id: vault_entry.to_param}, session: valid_session
      expect(assigns(:vault_entry)).to eq(vault_entry)
    end
  end

  describe "GET #new" do
    it "assigns a new vault_entry as @vault_entry" do
      get :new, params: {}, session: valid_session
      expect(assigns(:vault_entry)).to be_a_new(VaultEntry)
    end
  end

  describe "GET #edit" do
    it "assigns the requested vault_entry as @vault_entry" do
      vault_entry = VaultEntry.create! valid_attributes
      get :edit, params: {id: vault_entry.to_param}, session: valid_session
      expect(assigns(:vault_entry)).to eq(vault_entry)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:contacts) { 3.times.map { create(:contact, user_id: user.id) } }
      let(:documents) { [create(:document), create(:document)] } 
      
      it "creates a new VaultEntry" do 
        expect { post :create, params: {vault_entry: valid_attributes}, session: valid_session }
          .to change(VaultEntry, :count).by(1)
      end

      context "with attributes" do
        let!(:valid_attributes) do
          {
            user_id: user.id,
            primary_beneficiary_ids: contacts.first(2).map(&:id),
            secondary_beneficiary_ids: contacts.last(1).map(&:id),
            executor_ids: contacts[1].id,
            agent_ids: contacts.map(&:id),
            share_ids: contacts.map(&:id),
            document_ids: documents.map(&:id),
          }
        end

        let(:vault_entry) { assigns(:vault_entry) }

        before do
          post :create, vault_entry: valid_attributes, session: valid_session
        end

        it "assigns a newly created vault_entry as @vault_entry" do
          expect(vault_entry).to be_a(VaultEntry)
          expect(vault_entry).to be_persisted
        end

        it "assigns primary beneficiaries" do
          rich_association = vault_entry.vault_entry_beneficiaries.first
          beneficiaries = vault_entry.primary_beneficiaries

          expect(beneficiaries).to eq contacts.first(2)
        end

        it "assigns secondary beneficiaries" do
          beneficiaries = vault_entry.secondary_beneficiaries

          expect(beneficiaries).to eq contacts.last(1)
        end

        it "assigns agents" do
          expect(vault_entry.agents).to eq contacts
        end

        it "assigns shares" do
          expect(vault_entry.shares.size).to eq (contacts.size * documents.size)
        end

        it "assigns documents" do
          expect(vault_entry.documents).to eq documents
        end

        it "assigns executor" do
          expect(vault_entry.executor).to eq contacts[1]
        end

        it "assigns user" do
          expect(vault_entry.user).to eq user
        end
      end

      it "redirects to the created vault_entry" do
        post :create, params: {vault_entry: valid_attributes}, session: valid_session
        expect(response).to redirect_to(VaultEntry.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved vault_entry as @vault_entry" do
        post :create, params: {vault_entry: invalid_attributes}, session: valid_session
        expect(assigns(:vault_entry)).to be_a_new(VaultEntry)
      end

      it "re-renders the 'new' template" do
        post :create, params: {vault_entry: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested vault_entry" do
        vault_entry = VaultEntry.create! valid_attributes
        put :update, params: {id: vault_entry.to_param, vault_entry: new_attributes}, session: valid_session
        vault_entry.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested vault_entry as @vault_entry" do
        vault_entry = VaultEntry.create! valid_attributes
        put :update, params: {id: vault_entry.to_param, vault_entry: valid_attributes}, session: valid_session
        expect(assigns(:vault_entry)).to eq(vault_entry)
      end

      it "redirects to the vault_entry" do
        vault_entry = VaultEntry.create! valid_attributes
        put :update, params: {id: vault_entry.to_param, vault_entry: valid_attributes}, session: valid_session
        expect(response).to redirect_to(vault_entry)
      end
    end

    context "with invalid params" do
      it "assigns the vault_entry as @vault_entry" do
        vault_entry = VaultEntry.create! valid_attributes
        put :update, params: {id: vault_entry.to_param, vault_entry: invalid_attributes}, session: valid_session
        expect(assigns(:vault_entry)).to eq(vault_entry)
      end

      it "re-renders the 'edit' template" do
        vault_entry = VaultEntry.create! valid_attributes
        put :update, params: {id: vault_entry.to_param, vault_entry: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested vault_entry" do
      vault_entry = VaultEntry.create! valid_attributes
      expect {
        delete :destroy, params: {id: vault_entry.to_param}, session: valid_session
      }.to change(VaultEntry, :count).by(-1)
    end

    it "redirects to the vault_entries list" do
      vault_entry = VaultEntry.create! valid_attributes
      delete :destroy, params: {id: vault_entry.to_param}, session: valid_session
      expect(response).to redirect_to(vault_entries_url)
    end
  end

end
