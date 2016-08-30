class Share < ActiveRecord::Base
  belongs_to :user
  scope :for_user, ->(user) {where(user: user)}
  belongs_to :document
  belongs_to :contact

  validates :document_id, presence: true
  validates :contact_id, presence: true
  validates :user_id, presence: true
end
