module ErrorsHelper
  def date_of_bitrh_error?(error_message)
    error_message.include?('User profile date of birth')
  end
  
  def date_of_birth_error(error_message)
    error_message.slice!('User profile date of birth')
    error_message
  end
end
