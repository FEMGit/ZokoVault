require 'rails_helper'

RSpec.describe "Vendors", type: :request do
  describe "GET /vendors" do
    xit "works! (now write some real specs)" do
      get vendors_path
      expect(response).to have_http_status(200)
    end
  end
end
