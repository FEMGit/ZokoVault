class FixStripeCustomerIssue < ActiveRecord::Migration
  def each_stripe_customer
    pager = Stripe::Customer.all(limit: 100)
    pager.auto_paging_each { |cu| yield(cu) }
  end
  
  def change
    each_stripe_customer do |customer|
      user = User.find_by(email: customer.email)
      if user && user.paid? && user.stripe_customer.blank?
        customer_id = customer.try(:id)
        if customer_id.present? && StripeCustomer.find_by(stripe_customer_id: customer_id).blank?
          StripeCustomer.create(user_id: user.id, stripe_customer_id: customer_id)
        end
      end
    end
  end
end
