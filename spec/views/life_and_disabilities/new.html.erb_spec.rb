require 'rails_helper'

RSpec.describe "life_and_disabilities/new", type: :view do
  before(:each) do
    assign(:contacts, [])
    assign(:life_and_disability, build(:life_and_disability))
  end

  it "renders new life form" do
    render

    assert_select "form[action=?][method=?]", lives_path, "post" do
    end
  end
end
