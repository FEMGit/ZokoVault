class StripeSubscription < ActiveRecord::Base
  belongs_to :user
  attr_accessor :card_number

  def self.plans
    @plans ||= Stripe::Plan.all.data
  end

  def self.plan(id)
    plans.detect { |x| x.id.eql? id }
  end

  # TODO we should make this logic explicit, and not part of a callback
  before_create do
    new_sub = StripeService.subscribe(
      user:       user,
      token:      stripe_token,
      plan_id:    plan_id,
      promo_code: promo_code
    )
    self.subscription_id = new_sub.id
    self.customer_id = new_sub.customer
    self.last4 = card_number.last(4) # TODO not PCI compliant
    SubscriptionService.create_from_stripe(
      user: user, stripe_subscription_object: new_sub)
  end

  def customer
    @customer ||= Stripe::Customer.retrieve customer_id
  end

  def plan
    @plan ||= Stripe::Plan.retrieve plan_id
  end

  def apply_discount(discount)
    cust_object = Stripe::Customer.retrieve user.stripe_id
    sub_object = cust_object.subscriptions.data[0]
    sub_object.coupon = discount.id
    sub_object.save
    refresh!
  end

private

  # TODO is this being used?
  def initialize_payment_for(customer)
    payment_data = set_payment_data customer
    {
      id: payment_data.id,
      funding: payment_data.funding,
      last4: payment_data.last4,
      brand: payment_data.brand,
      country: payment_data.country,
      exp_month: payment_data.exp_month,
      exp_year: payment_data.exp_year,
      cvc_check: payment_data.cvc_check,
      fingerprint: payment_data.fingerprint
    }
  end
end