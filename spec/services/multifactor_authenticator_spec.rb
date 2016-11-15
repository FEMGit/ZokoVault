require 'rails_helper'

RSpec.describe MultifactorAuthenticator, type: :services do
  let!(:user) { create(:user) }
  let!(:phone_code) { MultifactorPhoneCode.generate_for(user) }
  let!(:country_code) { '+1' }

  subject { MultifactorAuthenticator.new(user) }

  describe "#send_code" do
    before { user.user_profile.phone_number_mobile = '111-111-1111' }

    it "generates a code" do
      expect(MultifactorPhoneCode).to receive(:generate_for).with(user).and_return(phone_code)

      messages = double
      allow(Twilio::REST::Client).to receive_message_chain(:new, messages: messages)
      expect(messages).to receive(:create).with(hash_including(to: "#{country_code}1111111111", body: "ZokuVault code is: #{phone_code.code}"))

      subject.send_code
    end
  end

  describe "#verify_code" do
    it "returns true it latest code" do
      expect(subject.verify_code(phone_code.code)).to be_truthy
    end

    it "returns false if not latest code" do
      latest_phone_code = MultifactorPhoneCode.generate_for(user)

      expect(subject.verify_code(phone_code.code)).to be_falsy
    end
  end
end
