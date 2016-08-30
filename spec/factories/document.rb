FactoryGirl.define do
  factory :document, class: 'Document' do
    name { Faker::File.file_name }
    url { Faker::Internet.url }
  end
end
