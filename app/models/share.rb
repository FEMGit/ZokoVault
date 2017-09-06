class Share < ActiveRecord::Base
  before_validation :validate_share, on: :create
  belongs_to :user
  scope :for_user, ->(user) {where(user: user)}
  scope :categories, -> { where(shareable_type: 'Category') }
  scope :for_category_and_contact, ->(category, contact) {
    where(shareable: category, contact: contact)
  }

  belongs_to :contact
  belongs_to :shareable, polymorphic: true

  validates :contact_id, presence: true
  
  def validate_share
    current_user = self.user || self.shareable.try(:user)
    contact_ids = Contact.for_user(current_user).map(&:id)
    if contact_ids.present? && (contact_ids.exclude? contact_id)
      self.errors.add(:contact_id, 'error saving contact as share - ' + contact_id.to_s)
    end
  end

  after_create do
    current_user = Thread.current[:current_user]
    unless current_user.present? && user && user.corporate_user_by_manager?(current_user)
      InvitationService::ShareInvitationService.send_invitation(user: user, contact: contact)
    end
  end
end
