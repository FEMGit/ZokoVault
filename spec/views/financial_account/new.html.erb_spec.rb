require 'rails_helper'

RSpec.describe "financial_account/new", type: :view do
  before(:each) do
    financial_account = FinancialAccountInformation.new
    financial_provider = FinancialProvider.new
    financial_provider.accounts << financial_account
    assign(:financial_provider, financial_provider)
    
    render
  end

  it "renders new financial provider form" do
    assert_select "form[action=?][method=?]", create_account_path, "post" do

      assert_select "input#financial_provider_name[name=?]", "financial_provider[name]"
      
      assert_select "input#financial_provider_web_address[name=?]", "financial_provider[web_address]"
      
      assert_select "input#financial_provider_street_address[name=?]", "financial_provider[street_address]"
      
      assert_select "input#financial_provider_city[name=?]", "financial_provider[city]"
      
      assert_select "select#financial_provider_state[name=?]", "financial_provider[state]"
      
      assert_select "input#financial_provider_zip[name=?]", "financial_provider[zip]"
      
      assert_select "input#financial_provider_phone_number[name=?]", "financial_provider[phone_number]"
      
      assert_select "input#financial_provider_fax_number[name=?]", "financial_provider[fax_number]"
      
      assert_select "select#financial_provider_primary_contact_id[name=?]", "financial_provider[primary_contact_id]"
      
      assert_select "select#financial_provider_share_with_contact_ids[name=?]", "financial_provider[share_with_contact_ids][]"
    end
  end
  
  it "renders new financial account form" do
    assert_select "form[action=?][method=?]", create_account_path, "post" do

      assert_select "select#financial_provider_account_0_account_type[name=?]",
                    "financial_provider[account_0][account_type]"
      
      assert_select "select#account_owner_0[name=?]",
                    "financial_provider[account_0][owner_id]"
      
      assert_select "input#account_value_0[name=?]",
                    "financial_provider[account_0][value]"
      
      assert_select "input#account_number_0[name=?]",
                    "financial_provider[account_0][number]"
      
      assert_select "select#account_broker_0[name=?]",
                    "financial_provider[account_0][primary_contact_broker_id]"
      
      assert_select "textarea#account_notes_0[name=?]",
                    "financial_provider[account_0][notes]"
    end
  end
end
