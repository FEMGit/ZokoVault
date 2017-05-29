FactoryGirl.define do
  factory :tutorial, class: 'Tutorial' do
    name "I have Insurance"
    content "Content of Tutorial 1"
    number_of_pages 1
    description "Insurance"
  end
end
