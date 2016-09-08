require 'rails_helper'

RSpec.describe "VendorAccounts", type: :request do
  let!(:user) { create :user }

  describe "GET /vendor_accounts" do
    xit "works! (now write some real specs)" do
      get vendor_accounts_path
      expect(response).to have_http_status(200)
    end
  end
end
