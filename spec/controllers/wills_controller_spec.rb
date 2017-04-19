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

  describe "GET #show" do
    it "assigns the requested will as @will" do
      @will = Will.create(valid_attributes)
      get :show, {id: @will.to_param}, session: valid_session
      expect(assigns(:will)).to eq(@will)
    end
  end

  describe "GET #new" do
    it "assigns a new vault_entry as @vault_entry" do
      get :new, {}, session: valid_session
      expect(assigns(:vault_entry)).to be_a_new(Will)
    end
  end

  describe "GET #edit" do
    it "assigns a new vault_entry as @vault_entry" do
      @will = Will.create(valid_attributes)
      get :edit, {id: @will.to_param}, session: valid_session
      expect(assigns(:vault_entry)).to eq(@will)
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
          primary_contact_ids = VaultEntryBeneficiary.where(will_id: vault_entry.id,
                                                            active: true,
                                                            type: VaultEntryBeneficiary::types[:primary]).map(&:contact_id)
          expect(primary_contact_ids).to eq contacts.first(2).map(&:id)
        end

        it "assigns secondary beneficiaries" do
          secondary_contact_ids = VaultEntryBeneficiary.where(will_id: vault_entry.id,
                                                              active: true,
                                                              type: VaultEntryBeneficiary::types[:secondary]).map(&:contact_id)
          expect(secondary_contact_ids).to eq contacts.last(1).map(&:id)
        end

        it "assigns agents" do
          agent_id = VaultEntryContact.where(contactable_id: vault_entry.id,
                                              type: VaultEntryContact.types[:agent]).map(&:contact_id).first
          expect(agent_id).to eq contacts[0].id
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
        expect(response).to render_template :new
      end
    end
  end

  let(:new_valid_attributes) do
    {
      title: "Title New",
      user_id: user.id,
      primary_beneficiary_ids: contacts.first(1).map(&:id),
      secondary_beneficiary_ids: contacts.first(1).map(&:id),
      executor_id: contacts[0].id,
      agent_ids: contacts[1].id,
      share_with_contact_ids: contacts.first(2).map(&:id)
    }
  end

  
  describe "PUT #update" do
    context "with invalid params" do
      it "redirects to the edit will page" do
        will = Will.create valid_attributes
        put :update, params: {id: will.id, vault_entry_0: invalid_attributes.merge(id: will.id)}, session: valid_session
        expect(response).to render_template :edit
      end
    end
    
    context "with valid params" do
      before :each do
        will = Will.create valid_attributes
        put :update, {id: will.id, vault_entry_0: new_valid_attributes.merge(id: will.id)}, session: valid_session
        @will = Will.find(will.id)
      end

      it "assigns new title" do
        expect(@will.title).to eq('Title New')
      end
      
      it "assigns primary beneficiaries" do
        primary_contact_ids = VaultEntryBeneficiary.where(will_id: @will.id,
                                                          active: true,
                                                          type: VaultEntryBeneficiary::types[:primary]).map(&:contact_id)
        expect(primary_contact_ids).to eq contacts.first(1).map(&:id)
      end

      it "assigns secondary beneficiaries" do
        secondary_contact_ids = VaultEntryBeneficiary.where(will_id: @will.id,
                                                            active: true,
                                                            type: VaultEntryBeneficiary::types[:secondary]).map(&:contact_id)
        expect(secondary_contact_ids).to eq contacts.first(1).map(&:id)
      end

      it "assigns agents" do
        agent_id = VaultEntryContact.where(contactable_id: @will.id,
                                            type: VaultEntryContact.types[:agent]).map(&:contact_id).first
        expect(agent_id).to eq contacts[1].id
      end

      it "assigns shares" do
        expect(@will.share_with_contact_ids).to eq contacts.first(2).map(&:id)
      end

      it "assigns executor" do
        expect(@will.executor).to eq contacts[0]
      end
    end
  end

  describe "DELETE #destroy" do
    before :each do
      request.env["HTTP_REFERER"] = "/wills"
    end

    it "destroys the requested vault_entry" do
      vault_entry = Will.create! valid_attributes
      expect { delete :destroy, { id: vault_entry.to_param }, session: valid_session }
        .to change(Will, :count).by(-1)
    end

    it "redirects to the vault_entries list" do
      vault_entry = Will.create! valid_attributes
      delete :destroy, { id: vault_entry.to_param }, session: valid_session
      expect(response).to redirect_to(wills_powers_of_attorney_path)
    end
  end

end
