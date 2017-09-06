class StripeService
  def self.stripe_customer(user:, corporate_update:)
    corporate_update ? ensure_corporate_stripe_customer(user: user) : ensure_stripe_customer(user: user)
  end

  def self.ensure_corporate_stripe_customer(user:)
    return nil unless user.corporate_admin
    if (customer_id = user.corporate_account_profile.stripe_customer_id).present?
      return Stripe::Customer.retrieve(customer_id)
    end
    customer = Stripe::Customer.create(
      email: user.email, description: user.name, metadata: { user_id: user.id })
    user.corporate_account_profile.update_attributes(:stripe_customer_id => customer.id)
    customer
  end
  
  def self.corporate_stripe_customers_invoices_history(user:)
    corporate_admin_customer_ids = CorporateAccountProfile.all.map(&:stripe_customer_id)
    user_corporate_stripe_subscriptions = StripeSubscription.all.select { |sub| sub.user == user &&
                                                                          corporate_admin_customer_ids.include?(sub.customer_id) }
    return [] unless user_corporate_stripe_subscriptions
    customers = user_corporate_stripe_subscriptions.map(&:customer_id).uniq.map { |customer_id| Stripe::Customer.retrieve(customer_id) }
    invoices = customers.map(&:invoices)
    user_subscription_ids = user_corporate_stripe_subscriptions.map(&:subscription_id)
    return [] unless invoices.present?
    invoices.map(&:data).flatten.select { |inv| user_subscription_ids.include?(inv[:lines][:data][0][:id]) }
  end

  def self.ensure_stripe_customer(user:)
    return user.stripe_customer if user.stripe_customer
    customer = Stripe::Customer.create(
      email: user.email, description: user.name, metadata: { user_id: user.id })
    user.create_stripe_customer_record(
      user_id: user.id, stripe_customer_id: customer.id)
    customer
  end

  def self.subscribe(customer:, plan_id:, promo_code: nil, metadata: {}, additional_params: {})
    subscription_attrs = { plan: plan_id, metadata: metadata }.merge(additional_params)
    subscription_attrs[:coupon] = promo_code if promo_code.present?
    customer.subscriptions.create(subscription_attrs)
  end
  
  def self.cancel_subscription(user:)
    subscription = user.current_user_subscription
    return if subscription.blank? || !subscription.full? ||
              subscription.subscription_id.blank?
    stripe_subscription = Stripe::Subscription.retrieve(subscription.subscription_id)
    stripe_subscription.delete(:at_period_end => true)
  end

  def self.customer_card(customer:)
    source = customer.try(:default_source)
    customer.sources.retrieve(source) if source.present?
  end
  
  def self.last_invoice_payment_amount(user:)
    if (stripe_customer = user.stripe_customer)
      invoice = stripe_customer.invoices.first
      invoice.total / 100.0
    else
      0
    end
  end

  def self.customer_id(user:)
    return nil unless user
    subscription = user.current_user_subscription
    return nil unless subscription
    record = subscription.funding.stripe_subscription_record
    return nil unless record
    record.customer_id
  end
  
  def self.cancel_subscription(subscription:)
    return false if subscription.blank? || !subscription.full? ||
              subscription.subscription_id.blank?
    begin
      stripe_subscription = Stripe::Subscription.retrieve(subscription.subscription_id)
      stripe_subscription.delete(:at_period_end => true)
    rescue Stripe::InvalidRequestError
      return false
    end
  end
end
