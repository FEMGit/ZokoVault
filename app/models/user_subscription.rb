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

  def active_trial?
    funding && funding.trial? && active?
  end

  def expired_trial?
    funding && funding.trial? && !active?
  end

  def active_full?
    funding && funding.full? && active?
  end

  def expired_full?
    funding && funding.full? && !active?
  end

end
