require 'rails_helper'

RSpec.describe Vendor, type: :model do

  describe "#destroy" do
    let!(:subject) { create(:vendor, :with_vendor_account) }

    it "destroys vendor account" do
      expect { subject.destroy }.to change(VendorAccount, :count).by(-1)
    end
  end
end
