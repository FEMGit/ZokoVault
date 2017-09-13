module InvitationService
  module VaultInheritanceInvitationService
    def self.send_invitation(user:, contact:)
      return unless contact.present? && user.present?
      
      invitation_args =
        if (user_contact = User.where('email ILIKE ?', contact.try(:emailaddress)).first).present?
          [:existing_user, user_contact, user]
        else
          [:new_user, contact, user]
        end

      VaultInheritanceInvitationMailer.send(*invitation_args).deliver_now
    end
  end
end