require 'rails_helper'

RSpec.describe TrustsController, type: :controller do
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:document) { create :document }
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Trust",
      user_id: user.id,
      trustee_ids: contacts.first(2).map(&:id),
      successor_trustee_ids: contacts.last(1).map(&:id),
      agent_ids: contacts.first(2).map(&:id),
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
    it "assigns all trusts as @trusts" do
      trust = create(:trust, user_id: user.id)
      get :index, {}, valid_session
      expect(assigns(:trusts)).to eq([trust])
    end
  end

  describe "GET #show" do
    it "assigns the requested trust as @trust" do
      @trust = Trust.create(valid_attributes)
      get :show, {id: @trust.to_param}, session: valid_session
      expect(assigns(:trust)).to eq(@trust)
    end
  end

  describe "GET #new" do
    it "assigns a new vault_entry as @vault_entry" do
      get :new, {}, session: valid_session
      expect(assigns(:vault_entry)).to be_a_new(Trust)
    end
  end

  describe "GET #edit" do
    it "assigns a new vault_entry as @vault_entry" do
      @trust = Trust.create(valid_attributes)
      get :edit, {id: @trust.to_param}, session: valid_session
      expect(assigns(:vault_entry)).to eq(@trust)
    end
  end

  describe "POST #create" do
    context "with invalid params" do
      it "redirects to the created vault_entry" do
        post :create, { vault_entry_0: invalid_attributes }, session: valid_session
        expect(response).to render_template(:new)
      end
    end

    context "with valid params" do
      it "creates a new Trust" do
        expect { post :create, { vault_entry_0: valid_attributes.merge(:id => "") }, session: valid_session }
          .to change(Trust, :count).by(1)
      end

      context "with attributes" do
        let(:vault_entry) { assigns(:new_vault_entries) }

        before do
          post :create, vault_entry_0: valid_attributes.merge(:id => ""), session: valid_session
        end

        it "assigns a newly created vault_entry as @vault_entry" do
          expect(vault_entry).to be_a(Trust)
          expect(vault_entry).to be_persisted
        end

        it "assigns name" do
          expect(vault_entry.name).to eq "Trust"
        end
        
        it "assigns trustees" do
          trustee_ids = VaultEntryContact.where(contactable_id: vault_entry.id,
                                              type: VaultEntryContact.types[:trustee]).map(&:contact_id)
          expect(trustee_ids).to eq contacts.first(2).map(&:id)
        end

        it "assigns successor trustees" do
          trustee_ids = VaultEntryContact.where(contactable_id: vault_entry.id,
                                              type: VaultEntryContact.types[:successor_trustee]).map(&:contact_id)
          expect(trustee_ids).to eq contacts.last(1).map(&:id)
        end

        it "assigns agents" do
          agent_ids = VaultEntryContact.where(contactable_id: vault_entry.id,
                                              type: VaultEntryContact.types[:agent]).map(&:contact_id)
          expect(agent_ids.sort).to eq contacts.first(2).map(&:id).sort
        end

        it "assigns shares" do
          expect(vault_entry.share_with_contacts.size).to eq contacts.size
        end

        it "assigns user" do
          expect(vault_entry.user).to eq user
        end
      end

      it "redirects to the created vault_entry" do
        post :create, { trust: valid_attributes }, session: valid_session
        expect(response).to be_success
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved vault_entry as @vault_entry" do
        post :create, { vault_entry_0: invalid_attributes }, session: valid_session
        expect(assigns(:new_vault_entries)).to be_a_new(Trust)
      end

      it "re-renders the 'new' template" do
        post :create, { trust: invalid_attributes }, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  let(:new_valid_attributes) do
    {
      name: "Trust New",
      user_id: user.id,
      trustee_ids: contacts.map(&:id),
      successor_trustee_ids: contacts.last(2).map(&:id),
      agent_ids: contacts.map(&:id),
      share_with_contact_ids: contacts.first(2).map(&:id),
      document_id: document.id
    }
  end
  
  describe "PUT #update" do
    context "with invalid params" do
      it "redirects to the edit trust page" do
        trust = Trust.create new_valid_attributes
        put :update, params: {id: trust.id, vault_entry_0: invalid_attributes.merge(id: trust.id)}, session: valid_session
        expect(response).to render_template :edit
      end
    end
  
    context "with valid params" do
      before :each do
        trust = Trust.create new_valid_attributes
        put :update, {id: trust.id, vault_entry_0: new_valid_attributes.merge(id: trust.id)}, session: valid_session
        @trust = Trust.find(trust.id)
      end

      it "assigns name" do
        expect(@trust.name).to eq "Trust New"
      end
      
      it "assigns trustees" do
        trustee_ids = VaultEntryContact.where(contactable_id: @trust.id,
                                            type: VaultEntryContact.types[:trustee]).map(&:contact_id)
        expect(trustee_ids).to eq contacts.map(&:id)
      end

      it "assigns successor trustees" do
        trustee_ids = VaultEntryContact.where(contactable_id: @trust.id,
                                            type: VaultEntryContact.types[:successor_trustee]).map(&:contact_id)
        expect(trustee_ids).to eq contacts.last(2).map(&:id)
      end

      it "assigns agents" do
        agent_ids = VaultEntryContact.where(contactable_id: @trust.id,
                                            type: VaultEntryContact.types[:agent]).map(&:contact_id)
        expect(agent_ids.sort).to eq contacts.map(&:id).sort
      end

      it "assigns shares" do
        expect(@trust.share_with_contacts.size).to eq contacts.first(2).size
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested vault_entry" do
      vault_entry = Trust.create! valid_attributes
      expect { delete :destroy, { id: vault_entry.to_param }, session: valid_session }
        .to change(Trust, :count).by(-1)
    end

    it "redirects to the trusts_entities_path" do
      vault_entry = Trust.create! valid_attributes
      delete :destroy, { id: vault_entry.to_param }, session: valid_session
      expect(response).to redirect_to(trusts_entities_path)
    end
  end
end
