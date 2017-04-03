FactoryGirl.define do
  factory :employer do
    name { Faker::Lorem.word }
    web_address { Faker::Internet.url }
    street_address_1 { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { "22222" }
    phone_number_office { generate :phone_number }
    phone_number_fax { generate :phone_number }
  end
end
