class MultifactorAuthenticator
  def initialize(user)
    @_user = user
  end

  def send_code
    MultifactorPhoneCode.transaction do
      code = MultifactorPhoneCode.generate_for(user)
#      client.messages.create(
#        from: TWILIO_PHONE_NUMBER,
#        to: user.phone_number,
#        body: "ZokuVault code is: #{code.code}")
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
end
