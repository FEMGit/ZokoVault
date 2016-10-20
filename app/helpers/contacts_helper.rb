module ContactsHelper
  def phone_number(phone)
    if(phone)
      number_to_phone(phone.gsub(/[^\d]/, ''), area_code: true)
    else
      phone
    end
  end
end
