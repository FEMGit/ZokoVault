require 'rails_helper'

RSpec.describe "financial_alternative/new", type: :view do
  before(:each) do
    financial_alternative = FinancialAlternative.new
    financial_provider = FinancialProvider.new
    financial_provider.alternatives << financial_alternative
    assign(:financial_provider, financial_provider)
    
    render
  end

  it "renders new financial provider form" do
    assert_select "form[action=?][method=?]", create_alternative_path, "post" do

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
  
  it "renders new financial alternative form" do
    assert_select "form[action=?][method=?]", create_alternative_path, "post" do

      assert_select "select#financial_provider_alternative_0_alternative_type[name=?]",
                    "financial_provider[alternative_0][alternative_type]"
      
      assert_select "select#alternative_owner_0[name=?]",
                    "financial_provider[alternative_0][account_owner_ids][]"
      
      assert_select "input#alternative_commitment_0[name=?]",
                    "financial_provider[alternative_0][commitment]"
      
      assert_select "input#alternative_total_calls_0[name=?]",
                    "financial_provider[alternative_0][total_calls]"
      
      assert_select "input#alternative_distributions_0[name=?]",
                    "financial_provider[alternative_0][total_distributions]"
      
      assert_select "input#alternative_current_value_0[name=?]",
                    "financial_provider[alternative_0][current_value]"
      
      assert_select "textarea#alternative_notes_0[name=?]",
                    "financial_provider[alternative_0][notes]"
    end
  end
end
