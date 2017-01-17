class Will < ActiveRecord::Base
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

  before_save { self.category = Category.fetch("wills - trusts - legal") }
end
