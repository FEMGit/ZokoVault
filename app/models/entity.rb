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

  has_many :partners, as: :contactable, dependent: :destroy, :class_name => 'AccountPolicyOwner'

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
    wills_poa = CardDocument.find_or_initialize_by(card_id: self.id, object_type: 'Entity')
    wills_poa.update(user_id: self.user_id, object_type: self.class, category: Category.fetch("trusts & entities"))
  end
  
  def delete_card_documents
    CardDocument.where(card_id: self.id, object_type: 'Entity').destroy_all
  end
end