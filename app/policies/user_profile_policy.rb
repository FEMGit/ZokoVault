class UserProfilePolicy < BasicPolicy

  def set_user_profile?
    user_owned?
  end

end
