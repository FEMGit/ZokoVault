class SubscriptionService
  def self.create_from_stripe(user:, stripe_subscription_object:, grace_period: 14.days)
    user_sub = UserSubscription.new
    user_sub.user = user
    user_sub.start_at = Time.at(stripe_subscription_object.start)
    user_sub.end_at = Time.at(stripe_subscription_object.current_period_end) + grace_period
    user_sub.build_funding(method: "stripe_subscription")
    user_sub.funding.details = { "stripe_subscription_id" => stripe_subscription_object.id }
    user_sub.save!
    CurrentUserSubscriptionMarker.set_for(
      user_id: user.id, user_subscription_id: user_sub.id)
    user_sub
  end

  def self.activate_trial(user:, duration:)
    user_sub = UserSubscription.new
    user_sub.user = user
    user_sub.start_at = Time.current
    user_sub.end_at = user_sub.start_at + duration
    user_sub.build_funding(method: "trial", details: {})
    user_sub.save!
    CurrentUserSubscriptionMarker.set_for(
      user_id: user.id, user_subscription_id: user_sub.id)
    user_sub
  end

  def self.trial_was_used?(user)
    UserSubscription.includes(:funding).where(user: user).map(&:funding).any?(&:trial?)
  end
end
