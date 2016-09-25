FactoryGirl.define do
  factory :user, class: 'User' do
    email { Faker::Internet.free_email }
    password 'password'
    password_confirmation 'password'
    confirmed_at { Time.now }
    setup_complete true

    after(:build) do |user|
      user.build_user_profile(mfa_frequency: :never)
    end
  end
end
