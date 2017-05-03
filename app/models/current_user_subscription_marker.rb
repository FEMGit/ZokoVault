class CurrentUserSubscriptionMarker < ActiveRecord::Base
  self.primary_key = :user_id

  belongs_to :user
  belongs_to :user_subscription

  validates :user_id, :user_subscription_id, presence: true, uniqueness: true

  def self.set_for(user_id:, user_subscription_id:)
    raise ArgumentError, "user_id cannot be blank for #{name}" if user_id.blank?
    existing = where(user_id: user_id).limit(1).first
    if existing
      existing.user_subscription_id = user_subscription_id
      existing.save!
    else
      create(user_id: user_id, user_subscription_id: user_subscription_id)
    end
  end
end
