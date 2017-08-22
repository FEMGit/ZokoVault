module SubscriptionHelper
  def subscription_days_remaining(subscription)
    return if subscription.blank?
    days_left = (subscription.end_at.utc - Time.current.utc) / 1.day
    (days_left <= 0) ? 0 : days_left.ceil
  end
end
