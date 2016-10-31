require 'rails_helper'

RSpec.describe "healths/edit", type: :view do
  before(:each) do
    assign(:contacts, [])
    @insurance_card = assign(:health, create(:health))
  end

  it "renders the edit health form" do
  end
end
