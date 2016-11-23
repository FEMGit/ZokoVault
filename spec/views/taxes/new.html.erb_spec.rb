require 'rails_helper'

RSpec.describe "taxes/new", type: :view do
  before(:each) do
    assign(:taxes, [])
    assign(:contacts, [])
    assign(:tax_year, TaxYearInfo.create!(:year => 2016))
  end

  it "renders new tax form" do
    render

    assert_select "form[action=?][method=?]", taxes_path, "post" do

      assert_select "#tax_preparer_id_0?"

      assert_select "#tax_notes_id_0?"
    end
  end
end
