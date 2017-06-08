class Will < ActiveRecord::Base
  # Friendly Id
  extend FriendlyId
  friendly_id :title
  
  def should_generate_new_friendly_id?
    title_changed? || (title.present? && slug.blank?)
  end
  
  include WtlBuildShares
  scope :for_user, ->(user) { where(user: user) }

  belongs_to :category
  belongs_to :user
  belongs_to :document
  belongs_to :executor, class_name: "Contact"

  has_many :vault_entry_beneficiaries, dependent: :destroy
  has_many :vault_entry_contacts, as: :contactable, dependent: :destroy
  has_many :shares, as: :shareable,  dependent: :destroy

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

  has_many :share_with_contacts, 
    through: :shares,
    source: :contact

  attr_accessor :has_will
  validates :user, presence: true
  validates :title, presence: { :message => "Required" }

  before_save { self.category = Category.fetch("wills - poa") }
  before_validation :build_shares
  after_save :clear_beneficiaries, :update_card_documents
  after_destroy :delete_card_documents
  
  def share_with_contact_ids
    @share_with_contact_ids || shares.map(&:contact_id)
  end

  attr_writer :share_with_contact_ids

  validates_length_of :title, :maximum => ApplicationController.helpers.get_max_length(:wtl_name)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
  
  private
    
  def clear_beneficiaries
    self.primary_beneficiaries.clear
    self.secondary_beneficiaries.clear
    self.agents.clear
  end
  
  def update_card_documents
    wills_poa = CardDocument.find_or_initialize_by(card_id: self.id, object_type: 'Will')
    wills_poa.update(user_id: self.user_id, object_type: self.class, category: Category.fetch("wills - poa"))
  end
  
  def delete_card_documents
    CardDocument.where(card_id: self.id, object_type: 'Will').destroy_all
  end
end
