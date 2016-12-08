FactoryGirl.define do
  factory :category do
    name { Faker::Business.name }
  end
end
