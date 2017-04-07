class Entity < ActiveRecord::Base
  include WtlBuildShares
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
    through: :shares,
    source: :contact

  has_many :partners,
    -> { where("vault_entry_contacts.type = ? AND vault_entry_contacts.active = ?",
               VaultEntryContact.types[:partner], true).uniq },
  through: :vault_entry_contacts,
  source: :contact

  validates :user, presence: true
  validates :name, presence: { :message => "Required" }
  
  before_save { self.category = Category.fetch("trusts & entities") }
  before_validation :build_shares
  
  def share_with_contact_ids
    @share_with_contact_ids || shares.map(&:contact_id)
  end

  attr_writer :share_with_contact_ids
  
  validates_length_of :name, :maximum => ApplicationController.helpers.get_max_length(:wtl_name)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
end