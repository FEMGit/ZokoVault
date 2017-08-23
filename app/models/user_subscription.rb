class UserSubscription < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
  
  belongs_to :user
  has_one :current_user_subscription_marker, dependent: :destroy

  has_one :funding, inverse_of: :user_subscription, dependent: :destroy

  validates :user, presence: true
  validates :funding, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true

  def active?(at: Time.current)
    (start_at && at >= start_at) && (end_at && at < end_at)
  end

  def trial?
    funding && funding.trial?
  end

  def full?
    funding && funding.full?
  end

  def active_trial?
    trial? && active?
  end

  def expired_trial?
    trial? && !active?
  end

  def active_full?
    full? && active?
  end

  def expired_full?
    full? && !active?
  end
  
  def corporate?(corporate_client:)
    corporate_owner = corporate_client.corporate_account_owner
    return false unless corporate_owner && corporate_client.corporate_user_by_admin?(corporate_owner)
    customer_id = corporate_owner.corporate_account_profile.stripe_customer_id
    stripe_record = funding.stripe_subscription_record
    stripe_record.present? && customer_id == stripe_record.customer_id
  end
  
  def subscription_id
    return nil unless funding && funding.details &&
                      funding.details["stripe_subscription_id"]
    funding.details["stripe_subscription_id"]
  end
end