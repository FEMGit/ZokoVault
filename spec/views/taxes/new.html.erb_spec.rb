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

      assert_select "select#tax_preparer_id_?"

      assert_select "textarea#tax_notes_id_?"
    end
  end
end
