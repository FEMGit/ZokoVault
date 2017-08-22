module ShareInvitationService
  def self.send_invitation(user, contact)
    if user.present? && contact.try(:emailaddress).present? &&
        contact.emailaddress =~ MailService.mail_regexp
      previously_invited = ShareInvitationSent.exists?(user_id: user.id,
                                                       contact_email: contact.emailaddress)
      shared_with_user = User.find_by(email: contact.emailaddress)
      return unless shared_with_user.present?
      
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
      end
    end
  end
  
  def self.send_corporate_invitation(corporate_contact, corporate_manager, account_type = "client")
    if corporate_manager.present? && corporate_contact.emailaddress =~ MailService.mail_regexp
      corporate_user = User.find_by(email: corporate_contact.emailaddress)
      corporate_admin = corporate_manager.corporate_employee? ? corporate_manager.corporate_admin_by_user : corporate_manager
      return unless corporate_user.corporate_user_by_admin?(corporate_admin)
      
      ShareInvitationMailer.corporate_user(corporate_contact, corporate_manager, account_type).deliver_now
      CorporateAdminAccountUser.where(corporate_admin: corporate_admin, user_account: corporate_user).update_all(confirmation_sent_at: Time.now)
    end
  end
end
