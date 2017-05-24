require 'set'

class Funding < ActiveRecord::Base

  belongs_to :user_subscription, inverse_of: :funding

  METHODS = Set.new(%w{
    beta_user_gift stripe_onetime_payment stripe_subscription trial
  }).freeze

  validates :user_subscription, presence: true
  validates :details, presence: true
  validates :method, inclusion: { in: METHODS }

  def trial?
    method == "trial"
  end

  def full?
    stripe_subscription? || onetime_payment? || beta?
  end

  def stripe_subscription?
    method == "stripe_subscription"
  end

  def onetime_payment?
    method == "stripe_onetime_payment"
  end

  def beta?
    method == "beta_user_gift"
  end

  def stripe_subscription_record
    return unless stripe_subscription?
    ssid = details["stripe_subscription_id"]
    return if ssid.blank?
    StripeSubscription.where(subscription_id: ssid).last
  end

end
