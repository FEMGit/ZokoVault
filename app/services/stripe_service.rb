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

  def self.subscribe(customer:, plan_id:, promo_code: nil, metadata: {})
    subscription_attrs = { plan: plan_id, metadata: metadata }
    subscription_attrs[:coupon] = promo_code if promo_code.present?
    customer.subscriptions.create(subscription_attrs)
  end

  def self.customer_card(customer:)
    source = customer.try(:default_source)
    customer.sources.retrieve(source) if source.present?
  end
  
  def self.customer_id(user:)
    return nil unless user
    subscription = user.current_user_subscription
    return nil unless subscription
    record = subscription.funding.stripe_subscription_record
    record.customer_id
  end
end
