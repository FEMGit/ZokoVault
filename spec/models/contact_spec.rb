require 'rails_helper'

RSpec.describe Contact, type: :model do

  describe "#canonical_user" do
    let(:user) { create :user }
    let(:contact) do
      create(:contact, emailaddress: user.email, user: user)
    end
    let(:non_user) { create :user }
    let(:non_user_contact) do
      create(:contact, emailaddress: user.email, user: non_user)
    end

    it "returns the user associated with the contact email address" do

      expect(contact.canonical_user).to eq(user)
      expect(non_user_contact.canonical_user).to eq(user)
    end
  end
end
