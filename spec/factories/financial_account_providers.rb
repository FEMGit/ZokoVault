FactoryGirl.define do
  factory :financial_account_provider, class: 'FinancialAccountProvider' do
    name "MyString"
    web_address "MyString"
    street_address "MyString"
    city "MyString"
    state "MyString"
    zip 1
    phone_number "MyString"
    fax_number "MyString"
  end
end
