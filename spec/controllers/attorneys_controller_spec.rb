require 'rails_helper'

RSpec.describe AttorneysController, type: :controller do

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "GET #details" do
  end

end
