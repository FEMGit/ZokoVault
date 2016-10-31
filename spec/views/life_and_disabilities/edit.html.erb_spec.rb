require 'rails_helper'

RSpec.describe "life_and_disabilities/edit", type: :view do
  before(:each) do
    assign(:contacts, [])
    @insurance_card = assign(:life_and_disability, create(:life_and_disability))
  end

  it "renders the edit life form" do
  end
end
