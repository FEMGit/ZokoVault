require 'rails_helper'

RSpec.describe FinancialAccountInformation, type: :model do
  subject { build(:financial_account_information) }

  describe "create" do
    context "on create" do
      it "creates a financial account information" do
        expect { subject.save }.to change { FinancialAccountInformation.count }.by(1)
      end
    end
  end
end
