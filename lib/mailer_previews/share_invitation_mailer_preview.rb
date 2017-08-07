class ShareInvitationMailerPreview < ActionMailer::Preview
  def new_user
    return unless user_contact_parameters.present?
    ShareInvitationMailer.new_user(user_contact_parameters[:contact], user_contact_parameters[:user])
  end
  
  def existing_user
    return unless existing_user_parameters.present?
    ShareInvitationMailer.existing_user(existing_user_parameters[:contact], existing_user_parameters[:user])
  end
  
  def corporate_user
    return unless user_contact_parameters.present?
    ShareInvitationMailer.corporate_user(user_contact_parameters[:contact], user_contact_parameters[:user])
  end
  
  private
  
  def user_contact_parameters
    return nil unless path_recognized
    user = path_user(path_recognized)
    contact = path_contact(user, path_recognized)
    return nil if user.blank? || contact.blank?
    { user: user, contact: contact }
  end
  
  def existing_user_parameters
    return nil unless path_recognized
    user = path_user(path_recognized)
    contact = path_contact(user, path_recognized)
    contact_user = User.find_by(email: contact.emailaddress)
    return nil if user.blank? || contact.blank? || contact_user.blank?
    { user: user, contact: contact_user }
  end
  
  def path_recognized
    path_recognized = Rails.application.routes.recognize_path(request.fullpath)
    return nil if path_recognized.blank? || path_recognized[:user_id].blank? || path_recognized[:user_id].blank?
    path_recognized
  end
  
  def path_user(path)
    User.find_by(id: path[:user_id])
  end
  
  def path_contact(user, path)
    if user.corporate_employee?
      Contact.for_user(user.corporate_admin_by_user).find_by(id: path[:contact_id])
    else
      Contact.for_user(user).find_by(id: path[:contact_id])
    end
  end
end
