class StripeCustomer < ActiveRecord::Base
  self.primary_key = :user_id

  belongs_to :user, inverse_of: :stripe_customer_record

  validates :user_id, presence: true, uniqueness: true
  validates :stripe_customer_id, presence: true

  def fetch
    @fetch ||= Stripe::Customer.retrieve(stripe_customer_id)
  end
end
