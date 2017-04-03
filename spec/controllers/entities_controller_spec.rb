require 'rails_helper'

RSpec.describe EntitiesController, type: :controller do

  let(:agent_contacts) { Array.new(2) { create(:contact, user_id: user.id) } }
  let(:partner_contacts) { Array.new(2) { create(:contact, user_id: user.id) } }
  let(:share_contacts) { Array.new(2) { create(:contact, user_id: user.id) } }
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Entity name",
      user_id: user.id,
      notes: 'Notes',
      agent_ids: agent_contacts.map(&:id),
      partner_ids: partner_contacts.map(&:id),
      share_with_contact_ids: share_contacts.map(&:id)
    }
  end

  let(:invalid_attributes) do
    { id: "", user_id: user.id, name: "" }
  end

  before { sign_in user }

  let(:valid_session) { {} }

  describe "GET #show" do
    before :each do
      post :create, { entity: valid_attributes}, session: valid_session
      @entity = assigns(:entity)
    end
    
    it "assigns the requested entity as @entity" do
      get :show, {id: @entity.to_param}, session: valid_session
      expect(assigns(:entity)).to eq(@entity)
    end
  end
  
  describe "GET #new" do
    it "assigns a new entity as @entity" do
      get :new, {}, session: valid_session
      expect(assigns(:entity)).to be_a_new(Entity)
    end
  end
  
  describe "GET #edit" do
    it "assigns the requested entity as @entity" do
      post :create, { entity: valid_attributes}, session: valid_session
      entity = assigns(:entity)
      get :edit, {id: entity.to_param}, session: valid_session
      expect(assigns(:entity)).to eq(entity)
    end
  end
  
  describe "POST #create" do
    context "with invalid params" do
      it "redirects to the create new entity page" do
        post :create, { entity: invalid_attributes }, session: valid_session
        expect(response).to render_template(:new)
      end
    end
    
    context "with valid params" do
      it "creates a new Entity" do
        expect {
          post :create, { entity: valid_attributes}, session: valid_session 
        }.to change(Entity, :count).by(1)
      end

      context "with attributes" do
        let(:entity) { assigns(:entity) }

        before do
          post :create, entity: valid_attributes, session: valid_session
        end

        it "assigns a newly created entity as @entity" do
          expect(entity).to be_a(Entity)
          expect(entity).to be_persisted
        end

        it "assigns agents" do
          agent_ids = VaultEntryContact.where(contactable_id: entity.id,
                                              type: VaultEntryContact.types[:agent]).map(&:contact_id)
          expect(agent_ids).to eq agent_contacts.map(&:id)
        end
        
        it "assigns partners" do
          partner_ids = VaultEntryContact.where(contactable_id: entity.id,
                                              type: VaultEntryContact.types[:partner]).map(&:contact_id)
          expect(partner_ids).to eq partner_contacts.map(&:id)
        end
        
        it "assigns name" do
          expect(entity.name).to eq "Entity name"
        end
        
        it "assigns notes" do
          expect(entity.notes).to eq "Notes"
        end

        it "assigns shares" do
          expect(entity.share_with_contacts.map(&:id).sort).to eq share_contacts.map(&:id).sort
        end

        it "assigns user" do
          expect(entity.user).to eq user
        end
        
        it "redirects to the created entity" do
          post :create, { entity: valid_attributes }, session: valid_session
          expect(response).to redirect_to entity_path(entity)
        end
      end
    end
    
    context "with invalid params" do
      it "assigns a newly created but unsaved entity as @entity" do
        post :create, { entity: invalid_attributes }, session: valid_session
        expect(assigns(:entity)).to be_a_new(Entity)
      end

      it "re-renders the 'new' template" do
        post :create, { entity: invalid_attributes }, session: valid_session
        expect(response).to render_template(:new)
      end
    end
  end
  
  let(:new_valid_attributes) do
    {
      name: "Entity name New",
      user_id: user.id,
      notes: 'Notes new',
      agent_ids: agent_contacts.first(1).map(&:id),
      partner_ids: partner_contacts.first(1).map(&:id),
      share_with_contact_ids: share_contacts.first(1).map(&:id)
    }
  end
  
  describe "POST #update" do
    context "with invalid params" do
      it "redirects to the create edit entity page" do
        entity = Entity.create! valid_attributes
        put :update, {id: entity.to_param, entity: invalid_attributes}, session: valid_session
        expect(response).to render_template(:edit)
      end
    end
    
    context "with valid params" do
      let(:entity) { assigns(:entity) }
      before do
        post :create, { entity: valid_attributes }, session: valid_session
        entity = assigns(:entity)

        put :update, {id: entity.to_param, entity: new_valid_attributes}, session: valid_session
        entity = assigns(:entity)
      end
      
      it "assigns name" do
        expect(entity.name).to eq "Entity name New"
      end

      it "assigns agents" do
        agent_ids = VaultEntryContact.where(contactable_id: entity.id,
                                            type: VaultEntryContact.types[:agent]).map(&:contact_id)
        expect(agent_ids).to eq agent_contacts.first(1).map(&:id)
      end

      it "assigns partners" do
        partner_ids = VaultEntryContact.where(contactable_id: entity.id,
                                            type: VaultEntryContact.types[:partner]).map(&:contact_id)
        expect(partner_ids).to eq partner_contacts.first(1).map(&:id)
      end

      it "assigns notes" do
        expect(entity.notes).to eq "Notes new"
      end

      it "assigns shares" do
        expect(entity.share_with_contacts.map(&:id).sort).to eq share_contacts.first(1).map(&:id).sort
      end

      it "assigns user" do
        expect(entity.user).to eq user
      end
    end
  end
  
  describe "DELETE #destroy" do
    it "destroys the requested trust" do
      entity = create(:entity, user_id: user.id)
      expect { delete :destroy, { id: entity.to_param }, valid_session }
        .to change(Entity, :count).by(-1)
    end

    it "redirects to the trusts & entities" do
      entity = create(:entity, user_id: user.id)
      delete :destroy, { id: entity.to_param }, valid_session
      expect(response).to redirect_to(trusts_entities_url)
    end
    
    it "shows correct flash message on destroy" do
      entity = create(:entity, user_id: user.id)
      delete :destroy, {id: entity.to_param}, valid_session
      expect(flash[:notice]).to be_present
    end
  end
end
