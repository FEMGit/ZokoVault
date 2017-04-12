class Subscription < ActiveRecord::Base
  belongs_to :user
  attr_accessor :card_number
  
  def self.plans
    @plans ||= Stripe::Plan.all.data
  end
  
  before_create do
    customer = Stripe::Customer.create({
      description: user.name,
      source: stripe_token,
      email: user.email
    })

    subscription_attrs = { plan: plan_id }
    subscription_attrs.merge!(coupon: promo_code) if promo_code.present?
    customer.subscriptions.create(subscription_attrs)

    self.last4 = card_number.last(4)
    self.customer_id = customer.id
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
