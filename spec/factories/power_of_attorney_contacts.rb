FactoryGirl.define do
  factory :power_of_attorney_contact do
    user { build(:user) }
  end
end
