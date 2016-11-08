require 'rails_helper'

RSpec.describe "healths/new", type: :view do
  before(:each) do
    assign(:contacts, [])
    assign(:contacts_shareable, [])
    @insurance_card = assign(:health, create(:health))
  end

  it "renders new health form" do
    render
  end
end
