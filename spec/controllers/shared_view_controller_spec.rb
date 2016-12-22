require 'rails_helper'

RSpec.describe SharedViewController, type: :controller do
  let!(:user) { create :user }
  let(:shared_user) { create :user }
  let(:contact) { create :contact, emailaddress: shared_user.email, user: shared_user }
  let!(:document) { create :document }

  let(:valid_attributes) do
    { 
      contact_id: contact.id, 
      shareable_type: "Document", 
      shareable_id: document.id, 
      user: user
    }
  end

  let(:invalid_attributes) { { contact: contact } }

  let(:valid_session) { {} }


  before do
    sign_in user
  end
end
