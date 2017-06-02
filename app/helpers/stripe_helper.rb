module StripeHelper
  def self.safe_request(on_failure: nil)
    yield
  rescue Stripe::InvalidRequestError, Stripe::CardError => se
    on_failure && on_failure.call(se)
  end
end