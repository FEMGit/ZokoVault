module UsersHelper
  def user_name(user_id)
    User.find(user_id).name
  end
  
  def corporate?
    return false unless current_user.present?
    current_user.present? && current_user.corporate_admin
  end
  
  def corporate_active?
    return false unless current_user.present?
    current_user.present? && current_user.corporate_admin &&
      current_user.corporate_activated
  end
end
