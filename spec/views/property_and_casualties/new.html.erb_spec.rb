require 'rails_helper'

RSpec.describe "property_and_casualties/new", type: :view do
  before(:each) do
    assign(:contacts, [])
    assign(:contacts_shareable, [])
    @insurance_card = assign(:property_and_casualty, create(:property_and_casualty))
  end

  it "renders new property form" do
    render
  end
end
