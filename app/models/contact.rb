class Contact < ActiveRecord::Base
  belongs_to :user

  scope :for_user, ->(user) {where(user: user)}
end
