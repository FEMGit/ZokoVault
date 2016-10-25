class PropertyAndCasualtyPolicy < ActiveRecord::Base

  enum policy_type: %w(Home Renters Vehicle Commercial Casualty Pet Other)

  belongs_to :policy_holder, class_name: "Contact"
  belongs_to :broker_or_primary_contact, class_name: "Contact"
end
