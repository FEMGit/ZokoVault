class SubscriptionService
  def self.create_from_stripe(stripe_sub, grace_period: 14.days)
    user_sub = UserSubscription.new
    user_sub.user = stripe_sub.user
    user_sub.start_at = Time.at(stripe_sub.start)
    user_sub.end_at = Time.at(stripe_sub.current_period_end) + grace_period
    user_sub.build_funding(method: "stripe_subscription")
    user_sub.funding.details = { "stripe_subscription_id" => stripe_sub.id }
    user_sub.save!
    CurrentUserSubscriptionMarker.set_for(
      user_id: user.id, user_subscription_id: user_sub.id)
    user_sub
  end
end
