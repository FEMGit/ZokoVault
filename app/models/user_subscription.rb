class UserSubscription < ActiveRecord::Base

  belongs_to :user
  has_one :current_user_subscription_marker, dependent: :destroy

  has_one :funding, inverse_of: :user_subscription, dependent: :destroy

  validates :user, presence: true
  validates :funding, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true

end
