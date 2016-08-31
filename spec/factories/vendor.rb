FactoryGirl.define do
  factory :vendor, class: 'Vendor' do
    name  { Faker::Company.name }

    trait :with_vendor_account do
      vendor_accounts { [build(:vendor_account)] }
    end
  end
end
