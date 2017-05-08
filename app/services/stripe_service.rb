class StripeService

  def self.ensure_stripe_customer(user:)
    return user.stripe_customer if user.stripe_customer
    customer = Stripe::Customer.create(
      email: user.email, metadata: { user_id: user.id })
    user.create_stripe_customer_record(
      user_id: user.id, stripe_customer_id: customer.id)
    customer
  end

  def self.subscribe(user:, token:, plan_id:, promo_code: nil)
    customer = Stripe::Customer.create({
      description:  user.name,
      source:       token,
      email:        user.email
    })
    subscription_attrs = { plan: plan_id }
    subscription_attrs[:coupon] = promo_code if promo_code.present?
    customer.subscriptions.create(subscription_attrs)
  end

end
