module StripeHelper
  def self.safe_request(on_failure: nil)
    yield
  rescue Stripe::InvalidRequestError, Stripe::CardError => se
    on_failure && on_failure.call(se)
  end
  
  def user_name_by_subscription_id(subscription_id)
    if stripe_subscription = StripeSubscription.find_by(:subscription_id => subscription_id)
      return '--' unless user = stripe_subscription.user
      user.name
    else
      '--'
    end
  end
end