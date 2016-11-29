class Trust < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }

  belongs_to :user
  belongs_to :document

  has_many :vault_entry_contacts, as: :contactable, dependent: :destroy
  has_many :shares, as: :shareable, dependent: :destroy

  has_many :agents,
    -> { where("vault_entry_contacts.type = ? AND vault_entry_contacts.active = ?",
               VaultEntryContact.types[:agent], true).uniq },
  through: :vault_entry_contacts,
  source: :contact

  has_many :share_with_contacts, 
    -> { uniq },
    through: :shares,
    source: :contact

  has_many :trustees,
    -> { where("vault_entry_contacts.type = ? AND vault_entry_contacts.active = ?",
               VaultEntryContact.types[:trustee], true).uniq },
  through: :vault_entry_contacts,
  source: :contact

  has_many :successor_trustees,
    -> { where("vault_entry_contacts.type = ? AND vault_entry_contacts.active = ?",
               VaultEntryContact.types[:successor_trustee], 
               true).uniq 
    },
    through: :vault_entry_contacts,
    source: :contact

  attr_accessor :has_trust
  # validates :agents, presence: true
  # validates :trustees, presence: true
  # validates :successor_trustees, presence: true
  # validates :shares, presence: true
  validates :user, presence: true
  validates :name, presence: true
  
end
