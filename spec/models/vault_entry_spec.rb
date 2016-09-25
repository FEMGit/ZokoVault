require 'rails_helper'

RSpec.describe VaultEntry, type: :model do
  let(:user) { create :user }
  let(:contacts) { 2.times.map { create(:contact, user_id: user.id) } } 

  it "has many documents" do
    5.times do |n|
      subject.documents.build
      expect(subject.documents.size).to eq (n+1)
    end
  end

  it "has many shares" do
    5.times do |n|
      subject.shares.build
      expect(subject.shares.size).to eq (n+1)
    end
  end

  it "has beneficiaries" do
    subject.vault_entry_beneficiaries
      .build(type: :secondary, percentage: 80, contact: contacts.last)
    subject.vault_entry_beneficiaries
      .build(type: :primary, percentage: 20, contact: contacts.first)

    subject.save!

    expect(subject.beneficiaries(true).map(&:firstname)).to eq contacts.map(&:firstname)
  end

  it "has an executor" do
    subject.vault_entry_contacts
      .build(type: :executor, contact: contacts.first)
    subject.save!
    subject.reload

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
