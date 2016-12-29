require 'rails_helper'

RSpec.describe FinancialAlternative, type: :model do
  subject { build(:financial_alternative) }

  describe "create" do
    context "on create" do
      it "creates a financial account information" do
        expect { subject.save }.to change { FinancialAccountInformation.count }.by(1)
      end
    end
  end
end
