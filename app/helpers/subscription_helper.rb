module SubscriptionHelper
  def subscription_days_remaining(subscription)
    days_left = (subscription.end_at - Time.current).to_i / (24 * 60 * 60)
    return 0 if days_left < 0
    (subscription.end_at - Time.current).to_i / (24 * 60 * 60) + 1
  end
  
  def trial_was_used?(user)
    UserSubscription.includes(:funding).where(user: user).map(&:funding).compact.any?(&:trial?)
  end
end