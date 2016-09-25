require 'rails_helper'

RSpec.describe MultifactorPhoneCode, type: :model do

  let(:user) {  double(id: 100) }

  describe "#generate_for" do

    it "creates a new code" do
      expect { MultifactorPhoneCode.generate_for(user) }
        .to change { MultifactorPhoneCode.count }.by(1)
    end
  end


  describe "#verify_latest" do
    it "verifies the latest code" do
      3.times do
        code = MultifactorPhoneCode.generate_for(user).code
        expect(MultifactorPhoneCode.verify_latest(user, code)).to be_truthy
      end
    end

    it "returns false no latest" do
      codes = 4.times.map do
        MultifactorPhoneCode.generate_for(user).code
      end

      codes.first(3).each do |code|
        expect(MultifactorPhoneCode.verify_latest(user, code)).to be_falsy
      end
    end
  end
end
