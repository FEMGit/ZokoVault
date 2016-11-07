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

  def verify_code(code)
    #MultifactorPhoneCode.verify_latest(user, code)
    true
  end

  private 

  attr_internal_reader :user

  def client
    Twilio::REST::Client.new
  end
  
  def phone_to_send_code_to
    @_user.user_profile.phone_number_mobile.split('-').join('').prepend(country_code)
  end
  
  def country_code
    "+1"
  end
end
