class PhoneService
  def self.format_phone_number(phone_number:)
    clear_phone_number = phone_number.gsub('-', '')
    return nil unless clear_phone_number.match(/d{10}/)
    clear_phone_number.split('-').join('').prepend(country_code)
  end
  
  def country_code
    "+1"
  end
end
