module ContactsHelper
  def show_street?(user_profile)
    !user_profile.street_address_1.blank? && !user_profile.city.blank? &&
      !user_profile.state.blank?
  end
  
  def show_email_address(email)
    if email.blank? || email.nil?
      ""
    else
      "www.#{email}"
    end
  end
end
