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
  
  def show_corporate_address?(corporate_profile)
    corporate_profile.street_address.present? && corporate_profile.city.present? &&
      corporate_profile.state.present?
  end
  
  def show_delete_button?(contact)
    contact.persisted? && contact != current_user.user_profile.contact && policy(contact).destroy?
  end

  def show_web_address(web_address)
    if web_address.blank? || web_address.nil?
      ""
    else
      "www.#{web_address}"
    end
  end
  
  def zip_code_form(form, name, errors = false)
    error_class = (errors.eql? true) ? " input-error" : ""
    form.text_field(name, class: "form-control zipcode-mask-field" + error_class, :maxlength => get_max_length(:zipcode), placeholder: '90210', type: 'tel')
  end
  
  def empty_image
    asset_url('blank.png')
  end
  
  def associated_user_logged_in?(contact)
    return 'No' if contact.blank? || contact.user_profile.blank?
    contact.user_profile.user.logged_in_at_least_once? ? 'Yes' : 'No'
  end
  
  def associated_user_invitation_sent?(contact)
    return 'No' if contact.blank? || contact.user_profile.blank?
    contact.user_profile.user.corporate_invitation_sent? ? 'Yes' : 'No'
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
  
  def error_key_to_field_name(error_key)
    case error_key
      when :emailaddress
        'Email Address'
      when :businesswebaddress
        'Business Web Address'
      else
        error_key
    end
  end
end
