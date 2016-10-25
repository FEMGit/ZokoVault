require 'rails_helper'

RSpec.describe "life_and_disabilities/edit", type: :view do
  before(:each) do
    assign(:contacts, [])
    @life_and_disability = assign(:life_and_disability, create(:life_and_disability))

  end

  it "renders the edit life form" do
    render

    assert_select "form[action=?][method=?]", lives_path(@life_and_disability), "post" do
    end
  end
end
