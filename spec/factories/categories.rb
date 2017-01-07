FactoryGirl.define do
  factory :category do
    name { Faker::App.name }
    description { Faker::App.name }
  end
end
