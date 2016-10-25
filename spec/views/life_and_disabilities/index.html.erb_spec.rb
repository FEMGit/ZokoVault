require 'rails_helper'

RSpec.describe "life_and_disabilities/index", type: :view do
  before(:each) do
    assign(:life_and_disabilities, [
      create(:life_and_disability),
      create(:life_and_disability)
    ])
  end

  it "renders a list of lives" do
    render
  end
end
