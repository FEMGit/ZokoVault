require 'rails_helper'

RSpec.describe "financial_account/edit", type: :view do
  
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:primary_contact_broker) { create(:contact, user_id: user.id) }
  
  let(:user) { create :user }
  
  let(:valid_attributes) do
    {
      name: "Provider Name",
      web_address: "www.zokuvault.com",
      street_address: "Street",
      city: "City",
      state: "State",
      zip: 55555,
      phone_number: "777-777-7777",
      fax_number: "888-888-8888",
      primary_contact_id: contacts.first.id,
      share_with_contact_ids: contacts.map(&:id),
      user_id: user.id
    }
  end
  
  let(:account_0) do 
    {
      account_type: "Bond",
      name: "Account Name",
      owner_id: contacts.second.id,
      value: "15000",
      primary_contact_broker_id: primary_contact_broker.id,
      notes: "Notes",
      user_id: user.id
    }
  end
  
  before(:each) do
    financial_account = FinancialAccountInformation.create! account_0
    financial_provider = FinancialProvider.create! valid_attributes
    financial_provider.accounts << financial_account
    @financial_provider = assign(:financial_provider, financial_provider)
    render
  end

  it "renders edit financial provider form" do

    assert_select "form[id=?][method=?]", "edit_financial_provider_#{@financial_provider.id}", "post" do

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
  
  it "renders edit financial account form" do
    
    assert_select "form[id=?]", "edit_financial_provider_#{@financial_provider.id}" do

      assert_select "select#financial_provider_account_0_account_type[name=?]",
                    "financial_provider[account_0][account_type]"
      
      assert_select "input#account_name_0[name=?]",
                    "financial_provider[account_0][name]"
      
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
