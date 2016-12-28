FactoryGirl.define do
  factory :financial_investment do
    name "MyString"
    investment_type 1
    owner_id 1
    value "9.99"
    web_address "MyString"
    phone_number "MyString"
    address "MyString"
    city "MyString"
    state "MyString"
    zip 1
    primary_contact_id 1
    notes 1
    user nil
  end
end
