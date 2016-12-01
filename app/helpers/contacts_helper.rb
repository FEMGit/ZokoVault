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
  
  def avatar_circle(contact, with_name = false)
    if contact.photourl.present?
      circle = image_tag(get_file_url(contact.photourl), class: "avatar-small", alt: contact.initials.to_s)
    else
      circle = image_tag(empty_image, class: "avatar-small", alt: contact.initials.to_s)
      p = content_tag(:p, contact.initials.to_s, class: "avatar-initials")
      circle.concat(p)
    end
    tooltip = content_tag(:div, user_tooltip_info(contact), class: "tooltip")
    tooltip_item = content_tag(:div, circle.concat(tooltip), class: "tooltip-item top")
    return tooltip_item unless with_name
    tooltip_item.concat(content_tag(:span, " #{contact.name}", class: "avatar-name"))
  end
  
  private
  
  def user_tooltip_info(contact)
    name = content_tag(:p, contact.name.to_s)
    email = mail_to(contact.emailaddress.to_s, contact.emailaddress.to_s, class: "no-underline-link")
    phone = content_tag(:p, contact.phone.to_s)
    name.concat(email).concat(phone)
  end
  
  def empty_image
    asset_url('blank.gif')
  end
end
