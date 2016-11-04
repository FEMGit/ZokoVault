require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  subject { build(:user_profile, user: build(:user)) }

  describe "#save" do
    context "on create" do
      it "creates a contact" do
        expect { subject.save }.to change { Contact.count }.by(1)
      end
    end
  end
end
