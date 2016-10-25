FactoryGirl.define do
  factory :property_and_casualty_policy do
    policy_type 1
    insured_property "MyString"
    policy_holder_id 1
    coverage_amount "9.99"
    brokery_or_primary_contact_id 1
    notes "MyString"
    vendor_id 1
    notes "MyString"
  end
end
