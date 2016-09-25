class VaultEntry < ActiveRecord::Base
  belongs_to :user

  has_many :documents

  has_many :vault_entry_beneficiaries
  has_many :vault_entry_contacts

  has_many :beneficiaries,
    -> { order("vault_entry_beneficiaries.type ASC") },
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

  def executor
    executors.first
  end
end
