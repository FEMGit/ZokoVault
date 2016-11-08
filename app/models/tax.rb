class Tax < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
end
