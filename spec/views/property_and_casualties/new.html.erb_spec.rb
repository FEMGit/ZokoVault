require 'rails_helper'

RSpec.describe "property_and_casualties/new", type: :view do
  before(:each) do
    assign(:contacts, [])
    assign(:property_and_casualty, PropertyAndCasualty.new)
  end

  it "renders new property form" do
    render

    assert_select "form[action=?][method=?]", properties_path, "post" do
    end
  end
end
