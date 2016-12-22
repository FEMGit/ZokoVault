module UserProfileHelper
  def web_address(employer)
    link_to(employer.web_address, employer.web_address)
  end
  
  def show_employer_card?(employer)
    employer.name.present? || employer.web_address.present? || show_street?(employer) ||
      employer.phone_number_office.present? || employer.phone_number_fax.present?
  end
end
