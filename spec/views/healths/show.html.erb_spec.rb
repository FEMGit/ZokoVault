require 'rails_helper'

RSpec.describe "healths/show", type: :view do
  before(:each) do
    @health = assign(:health, create(:health))
  end

  it "renders attributes in <p>" do
    render
  end
end
