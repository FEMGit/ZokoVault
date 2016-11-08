require 'rails_helper'

RSpec.describe "taxes/show", type: :view do
  before(:each) do
    @tax = assign(:tax, Tax.create!(
                          :document_id => "",
                          :tax_preparer_id => "",
                          :notes => "",
                          :user_id => "",
                          :tax_year => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
  end
end
