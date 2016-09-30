class VaultEntry < ActiveRecord::Base
  belongs_to :user

  has_many :documents

  has_many :vault_entry_beneficiaries
  has_many :vault_entry_contacts

  has_many :primary_beneficiaries,
    -> { where("vault_entry_beneficiaries.type = ?", VaultEntryBeneficiary.types[:primary]) },
    through: :vault_entry_beneficiaries,
    source: :contact

  has_many :secondary_beneficiaries,
    -> { where("vault_entry_beneficiaries.type = ?", VaultEntryBeneficiary.types[:secondary]) },
    through: :vault_entry_beneficiaries,
    source: :contact

  has_many :executors,
    -> { where("vault_entry_contacts.type = ? AND vault_entry_contacts.active = ?", 
               VaultEntryContact.types[:executor], true) },
    through: :vault_entry_contacts,
    source: :contact

  has_many :agents,
    -> { where("vault_entry_contacts.type = ? AND vault_entry_contacts.active = ?",
               VaultEntryContact.types[:agent], true) },
    through: :vault_entry_contacts,
    source: :contact

  has_many :shares
  has_many :share_with_contacts, 
    through: :shares,
    source: :contact

  attr_accessor :has_will

  def executor
    executors.first
  end
end
