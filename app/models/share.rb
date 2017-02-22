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
    if user.present? && contact.try(:emailaddress).present? &&
        contact.emailaddress =~ MailService.mail_regexp
      previously_invited = ShareInvitationSent.exists?(user_id: user.id,
                                                    contact_email: contact.emailaddress)
      unless previously_invited
        invitation_args =
          if (shared_with_user = User.find_by(email: contact.emailaddress))
            [:existing_user, shared_with_user, user]
          else
            [:new_user, contact, user]
          end

        ShareInvitationMailer.send(*invitation_args).deliver_now
        ShareInvitationSent.create(user_id: user.id, contact_email: contact.emailaddress)
      end
    end
  end
end
