FactoryGirl.define do
  factory :contact, class: 'Contact' do
    firstname { Faker::Name.first_name }
    emailaddress { Faker::Internet.free_email }
    user_id { 1 }
  end
end
