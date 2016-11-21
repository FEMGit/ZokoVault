module ContactsHelper
  def show_street?(user_profile)
    !user_profile.street_address_1.blank? && !user_profile.city.blank? &&
      !user_profile.state.blank?
  end

  def show_web_address(web_address)
    if web_address.blank? || web_address.nil?
      ""
    else
      web_address.to_s
    end
  end
end
