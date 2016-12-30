require 'rails_helper'

RSpec.describe FinancialProvider, type: :model do
  subject { build(:financial_provider) }

  describe "create" do
    context "on create" do
      it "creates a financial account provider" do
        expect { subject.save }.to change { FinancialProvider.count }.by(1)
      end
    end
  end
end
