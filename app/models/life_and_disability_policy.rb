class LifeAndDisabilityPolicy < ActiveRecord::Base

  enum policy_type: [ "Digital", "Term Life", "Whole Life", "Universal Life", "Short Term Disability", "Long Term Disability", "Springing" ]

  belongs_to :policy_holder, class_name: "Contact"
  belongs_to :broker_or_primary_contact, class_name: "Contact"

  has_many :policy_beneficiaries, dependent: :destroy
  has_many :shares, as: :shareable,  dependent: :destroy

  has_and_belongs_to_many :primary_beneficiaries, class_name: "Contact",
    join_table: :life_and_disability_policies_primary_beneficiaries,
    association_foreign_key: :primary_beneficiary_id
  has_and_belongs_to_many :secondary_beneficiaries, class_name: "Contact",
    join_table: :life_and_disability_policies_secondary_beneficiaries,
    association_foreign_key: :secondary_beneficiary_id
end

