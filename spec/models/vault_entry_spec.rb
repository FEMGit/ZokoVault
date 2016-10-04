require 'rails_helper'

RSpec.describe VaultEntry, type: :model do
  let(:user) { create :user }
  let(:contacts) { 2.times.map { create(:contact, user_id: user.id) } } 

  it "has one document" do
    subject.build_document
    expect(subject.document).to_not be_nil
  end

  it "has many shares" do
    5.times do |n|
      subject.shares.build
      expect(subject.shares.size).to eq (n+1)
    end
  end

  context "with beneficiaries" do
    before do
      subject.vault_entry_beneficiaries
        .build(type: :secondary, percentage: 80, contact: contacts.last)
      subject.vault_entry_beneficiaries
        .build(type: :primary, percentage: 20, contact: contacts.first)

      subject.save!
    end

    it "has primary beneficiaries" do
      expect(subject.primary_beneficiaries(true)).to eq [contacts.first]
    end

    it "has secondary beneficiaries" do
      expect(subject.secondary_beneficiaries(true)).to eq [contacts.last]
    end
  end

  it "has an executor" do
    subject.update_attribute(:executor_id, contacts.first.id)

    expect(subject.executor).to eq contacts.first
  end

  it "has agents" do
    expect(subject.vault_entry_contacts).to eq []
    subject.vault_entry_contacts
      .build(type: :agent, contact: contacts.first)
    subject.vault_entry_contacts
      .build(type: :agent, contact: contacts.last)

    subject.save!
    expect(subject.agents).to eq contacts
  end
end
