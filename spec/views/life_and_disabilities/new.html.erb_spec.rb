require 'rails_helper'

RSpec.describe "life_and_disabilities/new", type: :view do
  before(:each) do
    assign(:contacts, [])
    assign(:contacts_shareable, [])
    @insurance_card = assign(:life_and_disability, create(:life_and_disability))
  end

  it "renders new life form" do
    render
  end
end
