class MultifactorAuthenticator
  def initialize(user)
    @_user = user
  end

  def send_code
    MultifactorPhoneCode.transaction do
      code = MultifactorPhoneCode.generate_for(user)
      client.messages.create(
        from: TWILIO_PHONE_NUMBER,
        to: phone_to_send_code_to,
        body: "ZokuVault code is: #{code.code}")
    end
  end
  
  def send_code_on_number(phone_number)
    MultifactorPhoneCode.transaction do
      code = MultifactorPhoneCode.generate_for(user)
      client.messages.create(
        from: TWILIO_PHONE_NUMBER,
        to: format_phone_number(phone_number),
        body: "ZokuVault code is: #{code.code}")
    end
  end

  def verify_code(code)
    MultifactorPhoneCode.verify_latest(user, code)
  end

  private

  attr_internal_reader :user

  def client
    Twilio::REST::Client.new
  end

  def phone_to_send_code_to
    format_phone_number(@_user.user_profile.two_factor_phone_number)
  end
  
  def format_phone_number(phone_number)
    phone_number.split('-').join('').prepend(country_code)
  end

  def country_code
    "+1"
  end
end
