module InvitationService
  module CreateInvitationService
    def self.send_corporate_invitation(corporate_contact:, corporate_manager:, account_type: "client")
      if corporate_manager.present? && corporate_contact.emailaddress =~ MailService.mail_regexp
        corporate_user = User.find_by(email: corporate_contact.emailaddress)
        corporate_admin = corporate_manager.corporate_employee? ? corporate_manager.corporate_admin_by_user : corporate_manager
        return unless corporate_user.corporate_user_by_admin?(corporate_admin)

        CreateInvitationMailer.corporate_user(corporate_contact, corporate_manager, account_type).deliver_now
        UserTrafficModule.save_traffic_with_params(page_url: '--', page_name: "Corporate Invitation to #{corporate_contact.name}", user: corporate_manager, ip_address: '--')
        CorporateAdminAccountUser.where(corporate_admin: corporate_admin, user_account: corporate_user).update_all(confirmation_sent_at: Time.now)
      end
    end

    def self.send_super_admin_invitation(super_admin_user:, user_invited:)
      CreateInvitationMailer.super_admin_user(super_admin_user, user_invited).deliver_now
    end
  end
end
