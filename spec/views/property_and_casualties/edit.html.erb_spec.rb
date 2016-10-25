require 'rails_helper'

RSpec.describe "property_and_casualties/edit", type: :view do
  before(:each) do
    assign(:contacts, [])
    @property_and_casualty = assign(:property_and_casualty, create(:property_and_casualty))
  end

  it "renders the edit property form" do
    render
    assert_select "form[action=?][method=?]", properties_path(@property_and_casualty), "post" do
    end
  end
end
