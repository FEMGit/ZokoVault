module InvitationService
  module VaultInheritanceInvitationService
    class << self
      include Rails.application.routes.url_helpers
      
      def send_invitation(user:, contact:)
        return unless contact.present? && user.present?

        invitation_args =
          if (user_contact = User.where('email ILIKE ?', contact.try(:emailaddress)).first).present?
            [:existing_user, user_contact, user]
          else
            [:new_user, contact, user]
          end
        VaultInheritanceInvitationMailer.send(*invitation_args).deliver_now
        UserTrafficModule.save_traffic_with_params(page_url: contact_path(contact), page_name: "Designated #{contact.name} as contingent owner", user: user, ip_address: '--')
      end
    end
  end
end