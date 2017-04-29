class CurrentUserSubscriptionMarker < ActiveRecord::Base
  self.primary_key = :user_id

  belongs_to :user
  belongs_to :user_subscription

  validates :user_id, :user_subscription_id, presence: true, uniqueness: true
end
