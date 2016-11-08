require 'rails_helper'

RSpec.describe "taxes/new", type: :view do
  before(:each) do
    assign(:tax, Tax.new(
                   :document_id => "",
                   :tax_preparer_id => "",
                   :notes => "",
                   :user_id => "",
                   :tax_year => 1
    ))
  end

  it "renders new tax form" do
    render

    assert_select "form[action=?][method=?]", taxes_path, "post" do

      assert_select "input#tax_document_id[name=?]", "tax[document_id]"

      assert_select "input#tax_tax_preparer_id[name=?]", "tax[tax_preparer_id]"

      assert_select "input#tax_notes[name=?]", "tax[notes]"

      assert_select "input#tax_user_id[name=?]", "tax[user_id]"

      assert_select "input#tax_tax_year[name=?]", "tax[tax_year]"
    end
  end
end
