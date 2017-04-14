require 'stripe_mock'

FactoryGirl.define do
  stripe_helper = StripeMock.create_test_helper
  StripeMock.start
  plan = stripe_helper.create_plan(
    id: "test_plan",
    amount: 100,
    name: "test-monthly-zoku-plan"
  )
  
  factory :user, class: 'User' do
    email { Faker::Internet.free_email }
    password 'fgfdfGFGGF56@%FSfghhfasgd5'
    password_confirmation 'fgfdfGFGGF56@%FSfghhfasgd5'
    confirmed_at { Time.now }
    setup_complete true

    after(:build) do |user|
      user.build_user_profile(mfa_frequency: :never, date_of_birth: Date.today - 14.year)
      user.stripe_id = Subscription.create(
        stripe_token: stripe_helper.generate_card_token,
        plan_id: plan.id,
        user_email: user.email
      ).id
    end
  end
  StripeMock.stop
end
