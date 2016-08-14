require "rails_helper"

RSpec.describe VendorAccountsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/vendor_accounts").to route_to("vendor_accounts#index")
    end

    it "routes to #new" do
      expect(:get => "/vendor_accounts/new").to route_to("vendor_accounts#new")
    end

    it "routes to #show" do
      expect(:get => "/vendor_accounts/1").to route_to("vendor_accounts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/vendor_accounts/1/edit").to route_to("vendor_accounts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/vendor_accounts").to route_to("vendor_accounts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/vendor_accounts/1").to route_to("vendor_accounts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/vendor_accounts/1").to route_to("vendor_accounts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/vendor_accounts/1").to route_to("vendor_accounts#destroy", :id => "1")
    end

  end
end
