FactoryGirl.define do
  factory :vault_entry_contact do
    vault_entry nil
    type 1
    active false
    contact nil
  end
end
