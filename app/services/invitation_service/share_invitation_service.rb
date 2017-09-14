module InvitationService
  module ShareInvitationService
    def self.send_invitation(user:, contact:)
      if user.present? && contact.try(:emailaddress).present? &&
          contact.emailaddress =~ MailService.mail_regexp
        previously_invited = ShareInvitationSent.exists?(user_id: user.id,
                                                         contact_email: contact.emailaddress)
        shared_with_user = User.find_by(email: contact.emailaddress)

        # Return in case if corporate user is not activated yet
        return if user && user.corporate_user? && !user.corporate_invitation_sent?

        unless previously_invited
          invitation_args =
            if shared_with_user.present?
              [:existing_user, shared_with_user, user]
            else
              [:new_user, contact, user]
            end

          ShareInvitationMailer.send(*invitation_args).deliver_now
          ShareInvitationSent.create(user_id: user.id, contact_email: contact.emailaddress, user_invite_status: invitation_args.first.to_s)
          UserTrafficModule.save_traffic_with_params(page_url: '--', page_name: "Share Invitation to #{invitation_args[1].name}", user: user, ip_address: '--')
        end
      end
    end
  end
end
