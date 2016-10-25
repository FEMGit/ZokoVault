require 'rails_helper'

RSpec.describe "property_and_casualties/index", type: :view do
  before(:each) do
    assign(:property_and_casualties, [
      create(:property_and_casualty),
      create(:property_and_casualty)
    ])
  end

  it "renders a list of properties" do
    render
  end
end
