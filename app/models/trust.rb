class Trust < ActiveRecord::Base
  # Friendly Id
  extend FriendlyId
  friendly_id :name
  
  def should_generate_new_friendly_id?
    name_changed? || slug.blank?
  end
  
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
  
  before_save { self.category = Category.fetch("trusts & entities") }
  before_validation :build_shares
  after_save :update_card_documents
  after_destroy :delete_card_documents
  
  def share_with_contact_ids
    @share_with_contact_ids || shares.map(&:contact_id)
  end

  attr_writer :share_with_contact_ids
  
  validates_length_of :name, :maximum => ApplicationController.helpers.get_max_length(:wtl_name)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
  
  private
  
  def update_card_documents
    wills_poa = CardDocument.find_or_initialize_by(card_id: self.id, object_type: 'Trust')
    wills_poa.update(user_id: self.user_id, object_type: self.class, category: Category.fetch("trusts & entities"))
  end
  
  def delete_card_documents
    CardDocument.where(card_id: self.id, object_type: 'Trust').destroy_all
  end
end
