module UsersHelper
  def user_name(user_id)
    User.find(user_id).name
  end
  
  def corporate?
    return false unless current_user.present?
    current_user.present? && current_user.corporate_admin
  end
end
