require 'rails_helper'

RSpec.describe "healths/edit", type: :view do
  before(:each) do
    assign(:contacts, [])
    @health = assign(:health, create(:health))
  end

  it "renders the edit health form" do
    render

    assert_select "form[action=?][method=?]", health_path(@health), "post" do
    end
  end
end
