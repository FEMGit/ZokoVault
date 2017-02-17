class LifeAndDisabilityPolicy < ActiveRecord::Base

  enum policy_type: [ "Term Life", "Whole Life", "Universal Life", "Short Term Disability", "Long Term Disability" ]

  belongs_to :policy_holder, class_name: "Contact"
  belongs_to :broker_or_primary_contact, class_name: "Contact"

  has_many :policy_beneficiaries
  has_many :shares, as: :shareable,  dependent: :destroy

  has_and_belongs_to_many :primary_beneficiaries, class_name: "Contact",
    join_table: :life_and_disability_policies_primary_beneficiaries,
    association_foreign_key: :primary_beneficiary_id
  has_and_belongs_to_many :secondary_beneficiaries, class_name: "Contact",
    join_table: :life_and_disability_policies_secondary_beneficiaries,
    association_foreign_key: :secondary_beneficiary_id
  
  validates :policy_type, inclusion: { in: LifeAndDisabilityPolicy::policy_types }

  validates_length_of :coverage_amount, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :policy_number, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
end

