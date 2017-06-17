module ContactsHelper
  def show_street?(user_profile)
    user_profile.street_address_1.present? && user_profile.city.present? &&
      user_profile.state.present?
  end
  
  def show_street_contact?(contact)
    contact.address.present? && contact.city.present? &&
      contact.state.present?
  end
  
  def show_street_contact_business?(contact)
    contact.business_street_address_1.present? && contact.city.present? &&
      contact.state.present?
  end

  def show_web_address(web_address)
    if web_address.blank? || web_address.nil?
      ""
    else
      "www.#{web_address}"
    end
  end
  
  def zip_code_form(form, name)
    form.text_field(name, class: "form-control zipcode-mask-field", :maxlength => get_max_length(:zipcode), placeholder: '90210', type: 'tel')
  end
  
  def empty_image
    asset_url('blank.png')
  end
  
  def contact_status(contact)
    return nil unless current_user
    if current_user.user_profile.primary_shared_with
                   .map { |sh| sh.emailaddress.downcase }
                   .include? contact.emailaddress.downcase
      'Co-Owner'
    else
      nil
    end
  end
end
