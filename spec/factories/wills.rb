FactoryGirl.define do
  factory :will do
    title "Title"
    document_id 1
    executor_id 1
    user { build(:user) }
  end
end
