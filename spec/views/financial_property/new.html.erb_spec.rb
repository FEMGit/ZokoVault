require 'rails_helper'

RSpec.describe "financial_property/new", type: :view do
  before(:each) do
    financial_property = FinancialProperty.new
    assign(:financial_property, financial_property)
    
    render
  end

  it "renders new financial property form" do
    assert_select "form[action=?][method=?]", create_property_path, "post" do

      assert_select "input#financial_property_name[name=?]", "financial_property[name]"
      
      assert_select "select#financial_property_property_type[name=?]", "financial_property[property_type]"
      
      assert_select "select#financial_property_property_owner_ids[name=?]", "financial_property[property_owner_ids][]"
      
      assert_select "input#financial_property_value[name=?]", "financial_property[value]"
      
      assert_select "input#financial_property_address[name=?]", "financial_property[address]"
      
      assert_select "input#financial_property_city[name=?]", "financial_property[city]"
      
      assert_select "select#financial_property_state[name=?]", "financial_property[state]"
      
      assert_select "input#financial_property_zip[name=?]", "financial_property[zip]"
      
      assert_select "select#financial_property_primary_contact_id[name=?]", "financial_property[primary_contact_id]"
      
      assert_select "textarea#financial_property_notes[name=?]", "financial_property[notes]"
      
      assert_select "select#financial_property_share_with_contact_ids[name=?]", "financial_property[share_with_contact_ids][]"
    end
  end
end
