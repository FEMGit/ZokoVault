class Trust < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }

  belongs_to :category
  belongs_to :document
  belongs_to :user

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
  validates :user, presence: true
  validates :name, presence: { :message => "Required" }
  
  before_save { self.category = Category.fetch("wills - trusts - legal") }
end
