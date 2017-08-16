class UserProfilePolicy < BasicPolicy
  def index?
    user_owned?
  end
  
  def edit?
    user_owned?
  end
  
  def update?
    user_owned?
  end
  
  def set_user_profile?
    user_owned?
  end
end
