module EmailHelper
  def share_mailer_name(user, contact)
    if user.present? && contact.try(:emailaddress).present? &&
        contact.emailaddress =~ MailService.mail_regexp && contact.user == user
      if (shared_with_user = User.find_by(email: contact.emailaddress))
        "existing_user"
      else
        "new_user"
      end
    end
  end
end
