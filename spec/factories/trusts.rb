FactoryGirl.define do
  factory :trust do
    document_id 1
    executor_id 1
    name "MyString"
    user { build(:user) }
  end
end
