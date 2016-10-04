FactoryGirl.define do
  factory :vault_entry_beneficiary do
    vault_entry_id 1
    active false
    percentage "9.99"
    type 1
    contact_id 1
  end
end
