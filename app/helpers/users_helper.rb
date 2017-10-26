module UsersHelper
  def user_name(user_id)
    User.find(user_id).name
  end
  
  def corporate_employee?
    return false unless current_user.present?
    current_user.present? && current_user.corporate_employee?
  end
  
  def corporate_admin?
    return false unless current_user.present?
    current_user.present? && current_user.corporate_admin
  end
  
  def corporate?
    return false unless current_user.present?
    current_user.present? && (current_user.corporate_admin || current_user.corporate_employee?)
  end
  
  def corporate_active?
    return false unless current_user.present?
    return true if current_user.corporate_employee?
    current_user.present? && current_user.corporate_admin &&
      current_user.corporate_activated
  end
  
  def user_invited?(user)
    user.confirmation_sent_at.present? ? 'User has been invited.' : 'User has not been invited.'
  end
  
  def is_expired_trial_user?(user:)
    is_trial_user?(user: user) && user.current_user_subscription.expired_trial? && !user.corporate_manager?
  end
  
  def is_trial_user?(user:)
    user && user.current_user_subscription &&
                    user.current_user_subscription.trial?
  end
end
