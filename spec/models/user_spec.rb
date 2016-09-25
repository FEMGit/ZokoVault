require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user, user_profile: UserProfile.new) }

  describe "#mfa_verify?" do
    context "signed in from previous ip" do
      before do
        subject.current_sign_in_ip = "127.0.0.1"
        subject.last_sign_in_ip = "127.0.0.1"
      end

      it "returns true for :always" do
        subject.user_profile.mfa_frequency = :always
        expect(subject).to be_mfa_verify
      end

      it "returns false for :never" do
        subject.user_profile.mfa_frequency = :never
        expect(subject).to_not be_mfa_verify
      end

      it "returns false for :new_ip" do
        subject.user_profile.mfa_frequency = :new_ip
        expect(subject).to_not be_mfa_verify
      end
    end

    context "signed in from new ip" do
      before do
        subject.current_sign_in_ip = "127.0.0.2"
        subject.last_sign_in_ip = "127.0.0.1"
      end

      it "returns true for :always" do
        subject.user_profile.mfa_frequency = :always
        expect(subject).to be_mfa_verify
      end

      it "returns false for :never" do
        subject.user_profile.mfa_frequency = :never
        expect(subject).to_not be_mfa_verify
      end

      it "returns true for :new_ip" do
        subject.user_profile.mfa_frequency = :new_ip
        expect(subject).to be_mfa_verify
      end
    end
  end
end
