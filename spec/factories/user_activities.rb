FactoryGirl.define do
  factory :user_activity do
    user nil
    login_date "2016-12-01"
    login_count 1
    session_length 1
  end
end
