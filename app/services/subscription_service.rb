class SubscriptionService
  def self.create_trial(user)
    return if !trial_permitted?(user)
    user_subscription = UserSubscription.create!(user: user, start_at: Time.now, end_at: Time.now + SubscriptionDuration::TRIAL,
                                               funding: Funding.new(method: "trial", details: { "": "" }))
    CurrentUserSubscriptionMarker.find_or_initialize_by(user: user).update_attribute(:user_subscription_id, user_subscription.id)
  end
  
  def self.create_stripe_subscription(user, customer, card_number, stripe_token, plan_id, promo_code)
    next_payment_data = DateTime.strptime(Stripe::Invoice.upcoming(:customer => customer.id)[:date].to_s, '%s')
    user_subscription = UserSubscription.create!(user: user, start_at: Time.now, end_at: next_payment_data,
                                             funding: Funding.new(method: "stripe_subscription",
                                                                  details: { "last4": card_number.last(4),
                                                                             "customer_id": customer.id,
                                                                             "stripe_token": stripe_token,
                                                                             "plan_id": plan_id,
                                                                             "promo_code": promo_code }))
    
    CurrentUserSubscriptionMarker.find_or_initialize_by(user: user).update_attribute(:user_subscription_id, user_subscription.id)
  end
  
  private
  
  def self.trial_permitted?(user)
    !UserSubscription.for_user(user).map(&:funding).any?(&:trial?)
  end
end
