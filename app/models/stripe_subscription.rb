class StripeSubscription < ActiveRecord::Base
  belongs_to :user
  attr_accessor :card_number

  def self.map_of_plans
    @map_of_plans ||=
      Stripe::Plan.all.data.reduce({}) do |acc,plan|
        acc[plan.id] = plan; acc
      end.freeze
  end

  def self.active_plans
    [yearly_plan, monthly_plan]
  end

  def self.yearly_plan
    map_of_plans[StripeConfig.yearly_plan_id]
  end

  def self.monthly_plan
    map_of_plans[StripeConfig.monthly_plan_id]
  end
  
  def self.plan_duration_name(plan_id:)
    if plan_id.eql? monthly_plan[:id]
      'monthly'
    elsif plan_id.eql? yearly_plan[:id]
      'yearly'
    else
      nil
    end
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
