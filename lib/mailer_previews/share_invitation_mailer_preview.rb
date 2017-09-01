class ShareInvitationMailerPreview < MailerPreview
  def share_invitation_email
    return unless user_contact_parameters.present?
    contact = user_contact_parameters[:contact]
    if User.where('email ILIKE ?', contact.try(:emailaddress)).first.present?
      existing_user
    else
      new_user
    end
  end
  
  def new_user
    return unless user_contact_parameters.present?
    ShareInvitationMailer.new_user(user_contact_parameters[:contact], user_contact_parameters[:user])
  end
  
  def existing_user
    return unless existing_user_parameters.present?
    ShareInvitationMailer.existing_user(existing_user_parameters[:contact], existing_user_parameters[:user])
  end
end
