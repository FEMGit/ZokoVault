FactoryGirl.define do
  factory :user, class: 'User' do
    email { Faker::Internet.free_email }
    password 'fgfdfGFGGF56@%FSfghhfasgd5'
    password_confirmation 'fgfdfGFGGF56@%FSfghhfasgd5'
    confirmed_at { Time.now }
    setup_complete true

    after(:build) do |user|
      stripe_helper = StripeMock.create_test_helper
      plan = begin
        Stripe::Plan.retrieve("test_plan")
      rescue Stripe::InvalidRequestError
        stripe_helper.create_plan(
          id: "test_plan",
          amount: 100,
          name: "test-monthly-zoku-plan"
        )
      end
      user.build_user_profile(mfa_frequency: :never, date_of_birth: Date.today - 14.year)
      user.stripe_id = Subscription.create(
        stripe_token: stripe_helper.generate_card_token(last4: "4242"),
        plan_id: plan.id,
        user: user,
        card_number: "4242424242424242"
      ).id
    end
  end
end
