FactoryGirl.define do
  factory :vendor_account, class: 'VendorAccount' do
    name  { Faker::Company.name }
  end
end

