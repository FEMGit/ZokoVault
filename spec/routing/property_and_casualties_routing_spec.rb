require "rails_helper"

RSpec.describe PropertyAndCasualtiesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/insurance/properties").to route_to("property_and_casualties#index")
    end

    it "routes to #new" do
      expect(:get => "/insurance/properties/new").to route_to("property_and_casualties#new")
    end

    it "routes to #show" do
      expect(:get => "/insurance/properties/1").to route_to("property_and_casualties#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/insurance/properties/1/edit").to route_to("property_and_casualties#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/insurance/properties").to route_to("property_and_casualties#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/insurance/properties/1").to route_to("property_and_casualties#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/insurance/properties/1").to route_to("property_and_casualties#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/insurance/properties/1").to route_to("property_and_casualties#destroy", :id => "1")
    end

  end
end
