require "rails_helper"

RSpec.describe InterestedUsersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/interested_users").to route_to("interested_users#index")
    end

    it "routes to #new" do
      expect(:get => "/interested_users/new").to route_to("interested_users#new")
    end

    it "routes to #show" do
      expect(:get => "/interested_users/1").to route_to("interested_users#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/interested_users/1/edit").to route_to("interested_users#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/interested_users").to route_to("interested_users#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/interested_users/1").to route_to("interested_users#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/interested_users/1").to route_to("interested_users#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/interested_users/1").to route_to("interested_users#destroy", :id => "1")
    end

  end
end
