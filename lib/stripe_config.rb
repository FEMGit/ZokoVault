module StripeConfig

  class SetupError < StandardError; end

  def self.live_mode?
    !!(Stripe.api_key =~ /live/)
  end

  def self.test_mode?
    !!(Stripe.api_key =~ /test/)
  end

  def self.yearly_plan_id
    ENV['STRIPE_YEARLY_PLAN'] ||
      case
      when live_mode? then 'zoku-annual-119.88'
      when test_mode? then 'zoku-yearly-v1'
      else raise SetupError, 'Stripe api_key issue'
      end
  end

  def self.monthly_plan_id
    ENV['STRIPE_MONTHLY_PLAN'] ||
      case
      when live_mode? then 'zoku-monthly-12.99'
      when test_mode? then 'zoku-monthly-v1'
      else raise SetupError, 'Stripe api_key issue'
      end
  end

end
