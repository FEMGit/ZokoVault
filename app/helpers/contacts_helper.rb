module ContactsHelper
  def show_street?(user_profile)
    !user_profile.street_address_1.blank? && !user_profile.city.blank? &&
      !user_profile.state.blank?
  end

  def show_web_address(web_address)
    if web_address.blank? || web_address.nil?
      ""
    else
      "www.#{web_address}"
    end
  end
  
  def zip_code_form(form, name)
    form.text_field(name, class: "form-control", :data => {:mask => '99999'})
  end
  
  def empty_image
    asset_url('blank.png')
  end
end
