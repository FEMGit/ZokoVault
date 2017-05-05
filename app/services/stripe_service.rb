class StripeService

  # TODO this should be on the client side for PCI
  def self.token(number, exp_month, exp_year, cvc)
    Stripe::Token.create(
      :card => {
        :number => number,
        :exp_month => exp_month,
        :exp_year => exp_year,
        :cvc => cvc
        }
      )
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
