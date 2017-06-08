class LifeAndDisabilityPolicy < ActiveRecord::Base
  # Friendly Id
  extend FriendlyId
  friendly_id :empty_friendly_id
  
  def should_generate_new_friendly_id?
    true
  end
  
  def empty_friendly_id; end

  enum policy_type: [ "Term Life", "Whole Life", "Universal Life", "Short Term Disability", "Long Term Disability" ]

  has_one :policy_holder, as: :contactable, dependent: :destroy, :class_name => 'AccountPolicyOwner'
  belongs_to :broker_or_primary_contact, class_name: "Contact"

  has_many :policy_beneficiaries
  has_many :shares, as: :shareable,  dependent: :destroy

  validates :policy_type, inclusion: { in: LifeAndDisabilityPolicy::policy_types }

  validates_length_of :coverage_amount, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :policy_number, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
  after_destroy :clean_beneficiaries
  
  def primary_beneficiary_ids
    LifeAndDisabilityPoliciesPrimaryBeneficiary.where(life_and_disability_policy_id: self.id).collect { |ac_ow| ac_ow.contact_id.present? ? ac_ow.contact_id.to_s + '_contact' : ac_ow.card_document_id.to_s + '_owner' }
  end
  
  def primary_beneficiaries
    LifeAndDisabilityPoliciesPrimaryBeneficiary.where(life_and_disability_policy_id: self.id).collect { |ac_ow| ac_ow.contact_id.present? ? Contact.find_by(id: ac_ow.contact_id) : CardDocument.find_by(id: ac_ow.card_document_id) }
  end
  
  def secondary_beneficiary_ids
    LifeAndDisabilityPoliciesSecondaryBeneficiary.where(life_and_disability_policy_id: self.id).collect { |ac_ow| ac_ow.contact_id.present? ? ac_ow.contact_id.to_s + '_contact' : ac_ow.card_document_id.to_s + '_owner' }
  end
  
  def secondary_beneficiaries
    LifeAndDisabilityPoliciesSecondaryBeneficiary.where(life_and_disability_policy_id: self.id).collect { |ac_ow| ac_ow.contact_id.present? ? Contact.find_by(id: ac_ow.contact_id) : CardDocument.find_by(id: ac_ow.card_document_id) }
  end
  
  private
  
  def clean_beneficiaries
    LifeAndDisabilityPoliciesPrimaryBeneficiary.where(life_and_disability_policy_id: self.id).destroy_all
    LifeAndDisabilityPoliciesSecondaryBeneficiary.where(life_and_disability_policy_id: self.id).destroy_all
  end
end

