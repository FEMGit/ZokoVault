FactoryGirl.define do
  factory :power_of_attorney do
    power_of_attorney_id 1
    user { build(:user) }
    powers ""
  end
end
