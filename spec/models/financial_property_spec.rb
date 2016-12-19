require 'rails_helper'

RSpec.describe FinancialProperty, type: :model do
  subject { build(:financial_property) }

  describe "create" do
    context "on create" do
      it "creates a financial property" do
        expect { subject.save }.to change { FinancialProperty.count }.by(1)
      end
    end
  end
end
