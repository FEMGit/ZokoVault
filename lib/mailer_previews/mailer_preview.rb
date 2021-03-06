class MailerPreview < ActionMailer::Preview
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
      user.corporate_admin_by_user.contacts.find_by(id: path[:contact_id])
    else
      user.contacts.find_by(id: path[:contact_id])
    end
  end
end
