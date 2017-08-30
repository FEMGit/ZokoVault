class ShareInvitationMailerPreview < MailerPreview
  def new_user
    return unless user_contact_parameters.present?
    ShareInvitationMailer.new_user(user_contact_parameters[:contact], user_contact_parameters[:user])
  end
  
  def existing_user
    return unless existing_user_parameters.present?
    ShareInvitationMailer.existing_user(existing_user_parameters[:contact], existing_user_parameters[:user])
  end
end
