class Share < ActiveRecord::Base
  scope :for_user, ->(user) {where(user: user)}

  belongs_to :user
  belongs_to :contact
  belongs_to :shareable, polymorphic: true

  validates :contact_id, presence: true
end