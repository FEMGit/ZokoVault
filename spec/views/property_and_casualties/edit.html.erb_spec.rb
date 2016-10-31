require 'rails_helper'

RSpec.describe "property_and_casualties/edit", type: :view do
  before(:each) do
    assign(:contacts, [])
    @insurance_card = assign(:property_and_casualty, create(:property_and_casualty))
  end

  it "renders the edit property form" do
  end
end
