require 'rails_helper'

RSpec.describe "taxes/edit", type: :view do
  before(:each) do
    assign(:taxes, [])
    assign(:contacts, [])
    assign(:tax, Tax.new)
  end

  it "renders the edit tax form" do
  end
end
