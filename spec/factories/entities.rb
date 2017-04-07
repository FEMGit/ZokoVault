FactoryGirl.define do
  factory :entity do
    name "MyString"
    user { build(:user) }
  end
end
