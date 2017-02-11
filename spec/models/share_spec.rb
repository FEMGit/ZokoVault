require 'rails_helper'

RSpec.describe Share, type: :model do
  subject { Share.new(contact: contact, user: resource_owner) }
  let(:resource_owner) { create(:user) }

  before do
    subject.valid?
    p subject.errors
  end

  describe "#after_create callback" do
    context "contact is existing user" do
      let(:user) { create(:user) }
      let(:contact) { create(:contact, emailaddress: user.email, user: resource_owner) }

      context "and has never been sent a share invite" do
        it "sends :existing_user email" do
          expect { subject.save! }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      context "and has been sent a share invite" do
        it "does not send :new_user email" do
          expect { 
            subject.save! 
            Share.create!(contact: contact, user: resource_owner)
          }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end
    end

    context "contact is not existing user" do
      let(:contact) { create(:contact, user: resource_owner) }

      context "and has never been sent a share invite" do
        it "sends :new_user email" do
          expect { subject.save! }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      context "and has been sent a share invite" do
        it "does not send :new_user email" do
          expect { 
            subject.save! 
            Share.create!(contact: contact, user: resource_owner)
          }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end
    end
  end
end
