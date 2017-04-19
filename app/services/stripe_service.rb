class StripeService
  def self.token(number, exp_month, exp_year, cvc)
    stripe_token = Stripe::Token.create(
      :card => {
        :number => number,
        :exp_month => exp_month,
        :exp_year => exp_year,
        :cvc => cvc
        }
      )
  end
end
