class S3ImageUrl < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
  belongs_to :user
end
