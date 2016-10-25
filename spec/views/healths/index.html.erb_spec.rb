require 'rails_helper'

RSpec.describe "healths/index", type: :view do
  before(:each) do
    assign(:healths, [
      create(:health),
      create(:health)
    ])
  end

  it "renders a list of healths" do
    render
  end
end
