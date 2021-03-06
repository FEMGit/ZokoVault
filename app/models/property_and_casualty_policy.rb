class PropertyAndCasualtyPolicy < ActiveRecord::Base

  enum policy_type: %w(Home Renters Vehicle Commercial Casualty Pet Other)

  has_one :policy_holder, as: :contactable, dependent: :destroy, :class_name => 'AccountPolicyOwner'
  belongs_to :broker_or_primary_contact, class_name: "Contact"
  
  validates :policy_type, inclusion: { in: PropertyAndCasualtyPolicy::policy_types }

  validates_length_of :insured_property, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :coverage_amount, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :policy_number, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
end
