FactoryGirl.define do
  factory :user, class: 'User' do
    email { Faker::Internet.free_email }
    password 'fgfdfGFGGF56@%FSfghhfasgd5'
    password_confirmation 'fgfdfGFGGF56@%FSfghhfasgd5'
    confirmed_at { Time.now }
    setup_complete true

    after(:build) do |user|
      user.build_user_profile(mfa_frequency: :never, date_of_birth: Date.today - 14.year)
    end
  end
end
