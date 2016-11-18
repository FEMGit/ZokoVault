require "rails_helper"

RSpec.describe FinalWishesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/final_wishes").to route_to("final_wishes#index")
    end

    it "routes to #new" do
      expect(:get => "/final_wishes/new").to route_to("final_wishes#new")
    end

    it "routes to #show" do
      expect(:get => "/final_wishes/1").to route_to("final_wishes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/final_wishes/1/edit").to route_to("final_wishes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/final_wishes").to route_to("final_wishes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/final_wishes/1").to route_to("final_wishes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/final_wishes/1").to route_to("final_wishes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/final_wishes/1").to route_to("final_wishes#destroy", :id => "1")
    end

  end
end
