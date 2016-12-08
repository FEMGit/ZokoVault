FactoryGirl.define do
  factory :user, class: 'User' do
    email { "#{rand(1E6)}#{Faker::Internet.free_email}" }
    password 'password'
    password_confirmation 'password'
    confirmed_at { Time.now }
    setup_complete true

    after(:build) do |user|
      user.build_user_profile(mfa_frequency: :never, date_of_birth: Date.today - 14.year)
    end
  end
end
