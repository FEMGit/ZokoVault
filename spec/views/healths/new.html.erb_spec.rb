require 'rails_helper'

RSpec.describe "healths/new", type: :view do
  before(:each) do
    assign(:contacts, [])
    assign(:health, build(:health))
  end

  it "renders new health form" do
    render

    assert_select "form[action=?][method=?]", healths_path, "post" do
    end
  end
end
