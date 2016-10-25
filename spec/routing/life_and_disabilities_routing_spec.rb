require "rails_helper"

RSpec.describe LifeAndDisabilitiesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/insurance/lives").to route_to("life_and_disabilities#index")
    end

    it "routes to #new" do
      expect(:get => "/insurance/lives/new").to route_to("life_and_disabilities#new")
    end

    it "routes to #show" do
      expect(:get => "/insurance/lives/1").to route_to("life_and_disabilities#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/insurance/lives/1/edit").to route_to("life_and_disabilities#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/insurance/lives").to route_to("life_and_disabilities#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/insurance/lives/1").to route_to("life_and_disabilities#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/insurance/lives/1").to route_to("life_and_disabilities#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/insurance/lives/1").to route_to("life_and_disabilities#destroy", :id => "1")
    end

  end
end
