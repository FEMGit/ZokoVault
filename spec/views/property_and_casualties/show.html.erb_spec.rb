require 'rails_helper'

RSpec.describe "property_and_casualties/show", type: :view do
  before(:each) do
    @insurance_card = assign(:property, PropertyAndCasualty.create!(name: "foo"))
  end

  it "renders attributes in <p>" do
    render
  end
end
