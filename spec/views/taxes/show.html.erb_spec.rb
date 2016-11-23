require 'rails_helper'

RSpec.describe "taxes/show", type: :view do
  before(:each) do
    @tax = assign(:tax, TaxYearInfo.create!(
                          :user_id => "",
                          :year => 2
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
