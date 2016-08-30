FactoryGirl.define do
  factory :contact, class: 'Contact' do
    firstname { Faker::Name.first_name }
  end
end
