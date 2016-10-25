require "rails_helper"

RSpec.describe HealthsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/insurance/healths").to route_to("healths#index")
    end

    it "routes to #new" do
      expect(:get => "/insurance/healths/new").to route_to("healths#new")
    end

    it "routes to #show" do
      expect(:get => "/insurance/healths/1").to route_to("healths#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/insurance/healths/1/edit").to route_to("healths#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/insurance/healths").to route_to("healths#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/insurance/healths/1").to route_to("healths#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/insurance/healths/1").to route_to("healths#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/insurance/healths/1").to route_to("healths#destroy", :id => "1")
    end

  end
end
