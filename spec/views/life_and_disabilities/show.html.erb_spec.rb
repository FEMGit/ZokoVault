require 'rails_helper'

RSpec.describe "life_and_disabilities/show", type: :view do
  before(:each) do
    @insurance_card = assign(:life_and_disability, create(:life_and_disability))
  end

  it "renders attributes in <p>" do
    render
  end
end
