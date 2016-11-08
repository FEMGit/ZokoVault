require 'rails_helper'

RSpec.describe "taxes/new", type: :view do
  before(:each) do
    assign(:taxes, [])
    assign(:contacts, [])
    assign(:tax, Tax.new)
  end

  it "renders new tax form" do
    render

    assert_select "form[action=?][method=?]", taxes_path, "post" do

      assert_select "select#tax_preparer_id_?"

      assert_select "textarea#tax_notes_id_?"
    end
  end
end
