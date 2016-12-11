class Share < ActiveRecord::Base
  belongs_to :user
  scope :for_user, ->(user) {where(user: user)}
  belongs_to :document
  belongs_to :contact
  belongs_to :shareable, polymorphic: true

  validates :contact_id, presence: true
end
