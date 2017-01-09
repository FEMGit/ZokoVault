class Share < ActiveRecord::Base
  belongs_to :user
  scope :for_user, ->(user) {where(user: user)}
  scope :categories, -> { where(shareable_type: 'Category') }
  scope :for_category_and_contact, ->(category, contact) {
    where(shareable: category, contact: contact)
  }
 

  belongs_to :contact
  belongs_to :shareable, polymorphic: true

  validates :contact_id, presence: true
end
