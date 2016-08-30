class Contact < ActiveRecord::Base
  belongs_to :user

  scope :for_user, ->(user) {where(user: user)}

  validates :firstname, presence: true
  validates :user_id, presence: true
end
