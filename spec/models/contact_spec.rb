require 'rails_helper'

RSpec.describe Contact, type: :model do

  describe "#canonical_user" do
    let(:user) { create :user }
    let(:contact) do
      Contact.find_by(emailaddress: user.email) || create(:contact, emailaddress: user.email, user: user)
    end

    it "returns the user associated with the contact email address" do

      expect(contact.canonical_user).to eq(user)
    end
  end
end
