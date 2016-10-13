class VaultEntry < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }

  belongs_to :user

  belongs_to :document
  belongs_to :executor, class_name: "Contact"

  has_many :vault_entry_beneficiaries, dependent: :destroy
  has_many :vault_entry_contacts, dependent: :destroy

  has_many :primary_beneficiaries,
    -> { where("vault_entry_beneficiaries.type = ?", VaultEntryBeneficiary.types[:primary]) },
    through: :vault_entry_beneficiaries,
    source: :contact

  has_many :secondary_beneficiaries,
    -> { where("vault_entry_beneficiaries.type = ?", VaultEntryBeneficiary.types[:secondary]) },
    through: :vault_entry_beneficiaries,
    source: :contact

  has_many :agents,
    -> { where("vault_entry_contacts.type = ? AND vault_entry_contacts.active = ?",
               VaultEntryContact.types[:agent], true) },
    through: :vault_entry_contacts,
    source: :contact
  
  has_many :trustee,
    -> { where("vault_entry_contacts.type = ? AND vault_entry_contacts.active = ?",
               VaultEntryContact.types[:agent], true) },
    through: :vault_entry_contacts,
    source: :contact
  
  has_many :succeeded_trustee,
    -> { where("vault_entry_contacts.type = ? AND vault_entry_contacts.active = ?",
               VaultEntryContact.types[:agent], true) },
    through: :vault_entry_contacts,
    source: :contact

  has_many :shares, dependent: :destroy
  has_many :share_with_contacts, 
    through: :shares,
    source: :contact

  attr_accessor :has_will
end