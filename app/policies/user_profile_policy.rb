class UserProfilePolicy < BasicPolicy

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def set_user_profile?
    user_owned?
  end
  
end
