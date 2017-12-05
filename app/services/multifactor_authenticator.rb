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
        formatted = PhoneService.format_phone_number(phone_number: phone_number)
        code = MultifactorPhoneCode.generate_for(
          user: user, phone_number: formatted
        )
        client.messages.create(
          from: TWILIO_PHONE_NUMBER, to: formatted,
          body: "ZokuVault code is: #{code.code}"
        )
      end
    end
  end

  def verify_code(code:, phone_number:)
    formatted = PhoneService.format_phone_number(phone_number: phone_number)
    MultifactorPhoneCode.verify(user: user, code: code, phone_number: formatted)
  end

  private

  attr_internal_reader :user

  def client
    Twilio::REST::Client.new
  end

  def phone_to_send_code_to
    @_user.user_profile.two_factor_phone_number
  end
end
