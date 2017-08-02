class StripeService
  def self.ensure_corporate_stripe_customer(user:)
    return nil unless user.corporate_admin
    customer = Stripe::Customer.create(
      email: user.email, description: user.name, metadata: { user_id: user.id })
    user.corporate_account_profile.update_attributes(:stripe_customer_id => customer.id)
    customer
  end
  
  def self.ensure_stripe_customer(user:)
    return user.stripe_customer if user.stripe_customer
    customer = Stripe::Customer.create(
      email: user.email, description: user.name, metadata: { user_id: user.id })
    user.create_stripe_customer_record(
      user_id: user.id, stripe_customer_id: customer.id)
    customer
  end

  def self.subscribe(customer:, plan_id:, promo_code: nil)
    subscription_attrs = { plan: plan_id }
    subscription_attrs[:coupon] = promo_code if promo_code.present?
    customer.subscriptions.create(subscription_attrs)
  end

end
