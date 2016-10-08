require 'rails_helper'

RSpec.describe WillsController, type: :controller do

  let(:user) { create(:user) }
  before do
    sign_in user
  end
  
  describe "GET #new" do
    it "returns http success" do
      get :new, {}
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "GET #details" do
    it "returns http success" do
      get :details, :will => 1
      expect(response).to have_http_status(:success)
    end
  end

end
