class PowerOfAttorney < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }

  POWERS = %w(Digital Financial Healthcare General Limited Durable Springing)

  has_many :vault_entry_contacts, as: :contactable, dependent: :destroy
  has_many :shares, as: :shareable, dependent: :destroy

  belongs_to :document
  belongs_to :user

  has_many :agents,
    -> { where("vault_entry_contacts.type = ? AND vault_entry_contacts.active = ?",
               VaultEntryContact.types[:power_of_attorney], true) },
  through: :vault_entry_contacts,
  source: :contact

  has_many :share_with_contacts, 
    through: :shares,
    source: :contact
end
