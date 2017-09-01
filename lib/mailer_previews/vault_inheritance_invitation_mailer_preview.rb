class VaultInheritanceInvitationMailerPreview < MailerPreview
  def contingent_owner
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
    VaultInheritanceInvitationMailer.new_user(user_contact_parameters[:contact], user_contact_parameters[:user])
  end
  
  def existing_user
    return unless user_contact_parameters.present?
    contact = user_contact_parameters[:contact]
    return unless (user = User.where('email ILIKE ?', contact.try(:emailaddress)).first).present?
    VaultInheritanceInvitationMailer.existing_user(user, user_contact_parameters[:user])
  end
end
