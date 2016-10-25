class Share < ActiveRecord::Base
  belongs_to :user
  scope :for_user, ->(user) {where(user: user)}
  belongs_to :document
  belongs_to :contact
  belongs_to :shareable

  # validates :document_id, presence: true XXX: Does this need validation?
  validates :contact_id, presence: true
  validates :user_id, presence: true
end
