FactoryGirl.define do
  factory :health_policy do
    policy_type 1
    policy_number "MyString"
    group_number "MyString"
    policy_holder_id 1
    brokery_or_primary_contact_id 1
    notes "MyString"
    vendor_id 1
  end
end
