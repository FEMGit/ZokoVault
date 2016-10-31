require "rails_helper"

RSpec.describe UserProfilesController, type: :routing do
  describe "routing" do

    it "routes to #new" do
      expect(:get => "/user_profile/new").to route_to("user_profiles#new")
    end

    it "routes to #show" do
      expect(:get => "/user_profile").to route_to("user_profiles#show")
    end

    it "routes to #edit" do
      expect(:get => "/user_profile/edit").to route_to("user_profiles#edit")
    end

    it "routes to #create" do
      expect(:post => "/user_profile").to route_to("user_profiles#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/user_profile").to route_to("user_profiles#update")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/user_profile").to route_to("user_profiles#update")
    end

    it "routes to #destroy" do
      expect(:delete => "/user_profile").to route_to("user_profiles#destroy")
    end
  end
end
