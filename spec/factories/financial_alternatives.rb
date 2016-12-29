FactoryGirl.define do
  factory :financial_alternatives do
    alternative_type 1
    owner_id 1
    current_value "9.99"
    total_calls "9.99"
    total_distributions "9.99"
    commitment "9.99"
    primary_contact 1
    notes "MyString"
    name "Investment Name"
  end
end
