FactoryGirl.define do
  factory :contact, class: 'Contact' do
    firstname { Faker::Name.first_name }
    user_id { 1 }
  end
end
