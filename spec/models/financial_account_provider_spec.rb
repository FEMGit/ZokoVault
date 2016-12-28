require 'rails_helper'

RSpec.describe FinancialAccountProvider, type: :model do
  subject { build(:financial_account_provider) }

  describe "create" do
    context "on create" do
      it "creates a financial account provider" do
        expect { subject.save }.to change { FinancialAccountProvider.count }.by(1)
      end
    end
  end
end
