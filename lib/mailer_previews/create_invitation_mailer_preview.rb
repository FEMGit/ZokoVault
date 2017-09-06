class CreateInvitationMailerPreview < MailerPreview
  def corporate_user
    return unless user_contact_parameters.present?
    CreateInvitationMailer.corporate_user(user_contact_parameters[:contact], user_contact_parameters[:user])
  end
  
  def corporate_employee
    return unless user_contact_parameters.present?
    CreateInvitationMailer.corporate_user(user_contact_parameters[:contact], user_contact_parameters[:user], "employee")
  end
end
