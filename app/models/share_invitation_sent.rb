class ShareInvitationSent < ActiveRecord::Base
  scope :for_user, ->(user) { where(user_id: user.id) }
end
