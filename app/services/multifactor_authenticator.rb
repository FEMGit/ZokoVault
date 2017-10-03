class MultifactorAuthenticator
  def initialize(user)
    @_user = user
  end

  def send_code
    send_code_on_number(phone_to_send_code_to)
  end

  def send_code_on_number(phone_number)
    MultifactorPhoneCode.transaction do
      if MultifactorPhoneCode.can_make_more?(user)
        code = MultifactorPhoneCode.generate_for(user)
        client.messages.create(
          from: TWILIO_PHONE_NUMBER,
          to: format_phone_number(phone_number),
          body: "ZokuVault code is: #{code.code}")
      end
    end
  end

  def verify_code(code)
    MultifactorPhoneCode.verify(user: user, code: code)
  end
  
  def valid_phone_number?(phone_number)
    response = lookup_client.phone_numbers.get(phone_number)
    response.phone_number
    return true
    
    rescue
      return false
  end

  private

  attr_internal_reader :user
  
  def lookup_client
    Twilio::REST::LookupsClient.new
  end

  def client
    Twilio::REST::Client.new
  end

  def phone_to_send_code_to
    @_user.user_profile.two_factor_phone_number
  end

  def format_phone_number(phone_number)
    phone_number.split('-').join('').prepend(country_code)
  end

  def country_code
    "+1"
  end
end
