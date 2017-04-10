FactoryGirl.define do
  factory :financial_provider, class: 'FinancialProvider' do
    name "MyString"
    provider_type "Account"
    web_address "MyString"
    street_address "MyString"
    city "MyString"
    state "IL"
    zip 11111
    phone_number "MyString"
    fax_number "MyString"
  end
end
