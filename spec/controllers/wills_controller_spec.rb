require 'rails_helper'

RSpec.describe WillsController, type: :controller do

  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:document) { create(:document) }
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      title: "Title",
      user_id: user.id,
      primary_beneficiary_ids: contacts.first(2).map(&:id),
      secondary_beneficiary_ids: contacts.last(1).map(&:id),
      executor_id: contacts[1].id,
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

  xdescribe "GET #index" do
    it "assigns all vault_entries as @vault_entries" do
      vault_entry = Will.create! valid_attributes
      get :index, {}, session: valid_session
      expect(assigns(:vault_entries)).to eq([vault_entry])
    end
  end

  xdescribe "GET #show" do
    it "assigns the requested vault_entry as @vault_entry" do
      vault_entry = Will.create! valid_attributes
      get :show, { id: vault_entry.to_param }, session: valid_session
      expect(assigns(:vault_entry)).to eq(vault_entry)
    end
  end

  describe "GET #new" do
    it "assigns a new vault_entry as @vault_entry" do
      get :new, {}, session: valid_session
      expect(assigns(:vault_entry)).to be_a_new(Will)
    end
  end

  xdescribe "GET #edit" do
    it "assigns the requested vault_entry as @vault_entry" do
      vault_entry = Will.create! valid_attributes
      get :edit, { id: vault_entry.to_param }, session: valid_session
      expect(assigns(:vault_entry)).to eq(vault_entry)
    end
  end

  describe "POST #create" do
    context "with invalid params" do
      it "redirects to the created vault_entry" do
        post :create, { vault_entry_0: invalid_attributes }, session: valid_session
        expect(response).to render_template :new
      end
    end

    context "with valid params" do
      it "creates a new Will" do 
        expect { post :create, { vault_entry_0: valid_attributes.merge(:id => "") }, session: valid_session }
          .to change(Will, :count).by(1)
      end

      context "with attributes" do
        let(:vault_entry) { assigns(:new_vault_entries) }

        before do
          post :create, {vault_entry_0: valid_attributes.merge(:id => "")}, session: valid_session
        end

        it "assigns a newly created vault_entry as @vault_entry" do
          expect(vault_entry).to be_a(Will)
          expect(vault_entry).to be_persisted
        end

        it "assigns primary beneficiaries" do
          expect(vault_entry.primary_beneficiaries).to eq contacts.first(2)
        end

        it "assigns secondary beneficiaries" do
          beneficiaries = vault_entry.secondary_beneficiaries

          expect(beneficiaries).to eq contacts.last(1)
        end

        it "assigns agents" do
          expect(vault_entry.agents.first).to eq contacts[0]
        end
        
        it "assigns document" do
          expect(vault_entry.document).to eq document
        end

        it "assigns shares" do
          expect(vault_entry.share_with_contacts.size).to eq contacts.size
        end

        it "assigns executor" do
          expect(vault_entry.executor).to eq contacts[1]
        end

        it "assigns user" do
          expect(vault_entry.user).to eq user
        end
      end

      it "redirects to the created vault_entry" do
        post :create, { vault_entry_0: valid_attributes }, session: valid_session
        expect(response).to be_redirect
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved vault_entry as @vault_entry" do
        post :create, { vault_entry_0: invalid_attributes }, session: valid_session
        expect(assigns(:new_vault_entries)).to be_a(Will)
      end

      it "re-renders the 'new' template" do
        post :create, { vault_entry_0: invalid_attributes }, session: valid_session
        expect(response).to redirect_to estate_planning_path
      end
    end
  end

  xdescribe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        skip("Add a hash of attributes valid for your model")
      end

      it "updates the requested vault_entry" do
        vault_entry = Will.create! valid_attributes
        put :update, { id: vault_entry.to_param, will: new_attributes }, session: valid_session
        vault_entry.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested vault_entry as @vault_entry" do
        vault_entry = Will.create! valid_attributes
        put :update, { id: vault_entry.to_param, will: valid_attributes }, session: valid_session
        expect(assigns(:vault_entry)).to eq(vault_entry)
      end

      it "redirects to the vault_entry" do
        vault_entry = Will.create! valid_attributes
        put :update, { id: vault_entry.to_param, will: valid_attributes }, session: valid_session
        expect(response).to redirect_to(vault_entry)
      end
    end

    context "with invalid params" do
      it "assigns the vault_entry as @vault_entry" do
        vault_entry = Will.create! valid_attributes
        put :update, { id: vault_entry.to_param, will: invalid_attributes }, session: valid_session
        expect(assigns(:vault_entry)).to eq(vault_entry)
      end

      it "re-renders the 'edit' template" do
        vault_entry = Will.create! valid_attributes
        put :update, { id: vault_entry.to_param, will: invalid_attributes }, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  xdescribe "DELETE #destroy" do
    it "destroys the requested vault_entry" do
      vault_entry = Will.create! valid_attributes
      expect { delete :destroy, { id: vault_entry.to_param }, session: valid_session }
        .to change(Will, :count).by(-1)
    end

    it "redirects to the vault_entries list" do
      vault_entry = Will.create! valid_attributes
      delete :destroy, { id: vault_entry.to_param }, session: valid_session
      expect(response).to redirect_to(vault_entries_url)
    end
  end

end
