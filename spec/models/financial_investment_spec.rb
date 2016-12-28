require 'rails_helper'

RSpec.describe FinancialInvestment, type: :model do
  subject { build(:financial_investment) }

  describe "create" do
    context "on create" do
      it "creates a financial investment" do
        expect { subject.save }.to change { FinancialInvestment.count }.by(1)
      end
    end
  end
end
