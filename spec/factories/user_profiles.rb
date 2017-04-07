FactoryGirl.define do
  sequence(:phone_number) do
    "#{rand(100..999)}-#{rand(100..999)}-#{rand(1000..9999)}"
  end

  factory :user_profile do
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth { rand(18..60).years.ago }
    signed_terms_of_service_at { rand(10).days.ago }
    phone_number { generate :phone_number }
    mfa_frequency { :never }
    phone_number_mobile { generate :phone_number }
    two_factor_phone_number { generate :phone_number }
    street_address_1 { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { "11111" }
  end
end
