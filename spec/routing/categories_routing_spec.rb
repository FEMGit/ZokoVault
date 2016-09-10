require "rails_helper"

RSpec.describe CategoriesController, type: :routing do describe "routing" do

    it "routes to #index" do
      expect(:get => "/categories").to route_to("categories#index")
    end

    it "routes to #new" do
      expect(:get => "/categories/new").to route_to("categories#new")
    end

    it "routes to #show" do
      expect(:get => "/categories/1").to route_to("categories#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/categories/1/edit").to route_to("categories#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/categories").to route_to("categories#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/categories/1").to route_to("categories#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/categories/1").to route_to("categories#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/categories/1").to route_to("categories#destroy", :id => "1")
    end

    context "non-resource routes" do
      it "routes insurance" do
        {
          'estate_planning' => 'categories#estate_planning',
          'final_wishes' => 'categories#final_wishes',
          'financial_information' => 'categories#financial_information',
          'healthcare_choices' => 'categories#healthcare_choices',
          'insurance' => 'categories#insurance',
          'shared' => 'categories#shared',
          'taxes' => 'categories#taxes',
          'web_accounts' => 'categories#web_accounts',
        }.each do |path, route|
          expect(get: path).to route_to(route)
        end
      end
    end
  end
end
