class HealthPolicy < ActiveRecord::Base
  enum policy_type: [ "Employer Health Care Plan", "Exchange Health Care Plan", "Medicare Part A", "Medicare Part B", "Medicare Part C", "Medicare Part D" ]

  belongs_to :policy_holder, class_name: "Contact"
  belongs_to :broker_or_primary_contact, class_name: "Contact"

  has_and_belongs_to_many :insured_members, class_name: "Contact",
    join_table: "health_policies_insured_members",
    association_foreign_key: :insured_member_id
  
  validates :policy_type, inclusion: { in: HealthPolicy::policy_types }
end
