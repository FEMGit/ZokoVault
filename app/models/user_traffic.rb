class UserTraffic < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
  scope :shared_traffic, ->(user) { where(shared_user_id: user.id) }

  belongs_to :user
end
