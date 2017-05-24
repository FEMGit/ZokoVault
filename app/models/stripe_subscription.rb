class StripeSubscription < ActiveRecord::Base
  belongs_to :user
  attr_accessor :card_number

  def self.map_of_plans
    @map_of_plans ||=
      Stripe::Plan.all.data.reduce({}) do |acc,plan|
        acc[plan.id] = plan; acc
      end.freeze
  end

  def self.plans
    map_of_plans.values
  end

  def self.yearly_plan
    map_of_plans[StripePlans::YEARLY_PLAN]
  end

  def customer
    @customer ||= Stripe::Customer.retrieve(customer_id)
  end

  def plan
    self.class.map_of_plans[plan_id]
  end

  def fetch
    @fetch ||= Stripe::Subscription.retrieve(subscription_id)
  end
end
