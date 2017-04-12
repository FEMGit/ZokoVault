require 'rails_helper'

RSpec.describe PowerOfAttorneysController, type: :controller do

  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:document) { create(:document) }
  let(:user) { create :user }
  let(:powers) { Hash[PowerOfAttorney::POWERS.sample(3).zip([true,true,true])] }
  
  let(:agent_valid) do
    {
      user_id: user.id,
      powers: powers,
      agent_ids: contacts[0].id,
      notes: 'Notes',
      document_id: document.id
    }
  end
  
  let(:power_of_attorney_contact_valid) do
    {
      user_id: user.id,
      contact_id: contacts[0].id,
      share_with_contact_ids: contacts.map(&:id),
      vault_entry_0: agent_valid
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
  
  describe "GET #show" do
    it "assigns the requested power_of_attorney_contact as @power_of_attorney_contact" do
      power_of_attorney_contact = PowerOfAttorneyContact.create(user: user)
      get :show, { id: power_of_attorney_contact.id }, valid_session
      expect(assigns(:power_of_attorney_contact)).to eq(power_of_attorney_contact)
    end
  end
  
  describe "GET #new_wills_poa" do
    it "assigns a new power_of_attorney_contact as @power_of_attorney_contact" do
      get :new_wills_poa, {}, session: valid_session
      expect(assigns(:power_of_attorney_contact)).to be_a_new(PowerOfAttorneyContact)
      expect(assigns(:power_of_attorney_contact).power_of_attorneys.first).to be_a_new(PowerOfAttorney)
    end
  end
  
  describe "GET #edit" do
    it "assigns the requested power_of_attorney_contact as @power_of_attorney_contact" do
      power_of_attorney_contact = PowerOfAttorneyContact.create(user: user)
      power_of_attorney = PowerOfAttorneyBuilder.new.build
      power_of_attorney_contact.power_of_attorneys << power_of_attorney
      
      get :edit, { id: power_of_attorney_contact.id }, valid_session
      expect(assigns(:power_of_attorney_contact)).to eq(power_of_attorney_contact)
      expect(assigns(:power_of_attorney_contact).power_of_attorneys).to eq(power_of_attorney_contact.power_of_attorneys)
    end
  end
  
  describe "POST #create" do
    context "with valid params" do
      it "creates a new PowerOfAttorney " do
        expect { post :create, { power_of_attorney_contact: power_of_attorney_contact_valid }, session: valid_session }
          .to change(PowerOfAttorneyContact, :count).by(1)
      end
      
      it "creates a new PowerOfAttorney agents" do
        expect { post :create, { power_of_attorney_contact: power_of_attorney_contact_valid }, session: valid_session }
          .to change(PowerOfAttorney, :count).by(1)
      end
      
      context "with attributes" do
        let(:power_of_attorney_contact) { assigns(:power_of_attorney_contact) }

        before do
          post :create, { power_of_attorney_contact: power_of_attorney_contact_valid }, session: valid_session
        end

        it "assigns a newly created vault_entry as @vault_entry" do
          expect(power_of_attorney_contact).to be_a(PowerOfAttorneyContact)
          expect(power_of_attorney_contact).to be_persisted
          expect(power_of_attorney_contact.power_of_attorneys.first).to be_a(PowerOfAttorney)
          expect(power_of_attorney_contact.power_of_attorneys.first).to be_persisted
        end
        
        it "assigns power of attorney for" do
          expect(power_of_attorney_contact.contact).to eq contacts[0]
        end
        
        it "assigns power of attorney share with contacts" do
          expect(power_of_attorney_contact.share_with_contacts.sort).to eq contacts.sort
        end
        
        it "assigns power of attorney agent powers" do
          expect(power_of_attorney_contact.power_of_attorneys.first.powers.keys.sort).to eq powers.keys.sort
        end
        
        it "assigns power of attorney agent contact" do
          agent_id = VaultEntryContact.where(contactable_id: power_of_attorney_contact.power_of_attorneys.first.id,
                                             type: VaultEntryContact.types[:power_of_attorney]).map(&:contact_id).first
          expect(agent_id).to eq contacts[0].id
        end
        
        it "assigns power of attorney agent notes" do
          expect(power_of_attorney_contact.power_of_attorneys.first.notes).to eq 'Notes'
        end
      end
    end
  end
  
  describe "PUT #update" do
    context "with valid params" do
      let(:new_powers) { Hash[PowerOfAttorney::POWERS.sample(3).zip([true,true,true])] }
      let(:new_agent_valid) do
        {
          user_id: user.id,
          powers: new_powers,
          agent_ids: contacts[1].id,
          notes: 'Notes New',
          document_id: document.id
        }
      end

      let(:new_power_of_attorney_contact_valid) do
        {
          user_id: user.id,
          contact_id: contacts[1].id,
          share_with_contact_ids: contacts.first(2).map(&:id),
          vault_entry_0: new_agent_valid
        }
      end
      
      let(:power_of_attorney_contact) { assigns(:power_of_attorney_contact) }

      before do
        power_of_attorney_contact = PowerOfAttorneyContact.create(user: user)
        put :update, { id: power_of_attorney_contact.id, power_of_attorney_contact: new_power_of_attorney_contact_valid }, session: valid_session
        power_of_attorney_contact.reload
      end

      it "updates the requested pofer attorney for contact" do
        expect(power_of_attorney_contact.contact_id).to eq(contacts[1].id)
      end
      
      it "assigns power of attorney share with contacts" do
        expect(power_of_attorney_contact.share_with_contacts.sort).to eq contacts.first(2).sort
      end

      it "assigns power of attorney agent powers" do
        expect(power_of_attorney_contact.power_of_attorneys.first.powers.keys.sort).to eq new_powers.keys.sort
      end

      it "assigns power of attorney agent contact" do
        agent_id = VaultEntryContact.where(contactable_id: power_of_attorney_contact.power_of_attorneys.first.id,
                                           type: VaultEntryContact.types[:power_of_attorney]).map(&:contact_id).first
        expect(agent_id).to eq contacts[1].id
      end

      it "assigns power of attorney agent notes" do
        expect(power_of_attorney_contact.power_of_attorneys.first.notes).to eq 'Notes New'
      end
    end
  end
  
  describe "DELETE #destroy" do
    context "Delete" do
      let(:power_of_attorney_contact) { assigns(:power_of_attorney_contact) }

      before do
        post :create, { power_of_attorney_contact: power_of_attorney_contact_valid }, session: valid_session
      end
      
      it "destroys the requested agent" do
        expect { delete :destroy, { id: power_of_attorney_contact.power_of_attorneys.first.id }, valid_session }
          .to change(PowerOfAttorney, :count).by(-1)
      end

      it "destroys the requested power of attorney" do
        expect { delete :destroy_power_of_attorney_contact, { id: power_of_attorney_contact.id }, valid_session }
          .to change(PowerOfAttorneyContact, :count).by(-1)
      end
      
      it "redirects to the wills powers of attorney summary page" do
        delete :destroy_power_of_attorney_contact, { id: power_of_attorney_contact.id }, valid_session
        expect(response).to redirect_to(wills_powers_of_attorney_path)
      end
    end
  end
end
