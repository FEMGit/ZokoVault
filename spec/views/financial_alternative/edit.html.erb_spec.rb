require 'rails_helper'

RSpec.describe "financial_alternative/edit", type: :view do
  
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:primary_contact) { create(:contact, user_id: user.id) }
  
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
  
  let(:alternative_0) do 
    {
      alternative_type: "Venture Capital",
      name: "Investment Name",
      owner_id: contacts.first.id,
      commitment: "99.99",
      total_calls: "99.99",
      total_distributions: "99.99",
      current_value: "99.99",
      primary_contact_id: primary_contact.id,
      notes: "Notes",
      user_id: user.id
    }
  end
  
  before(:each) do
    financial_alternative = FinancialAlternative.create! alternative_0
    financial_provider = FinancialProvider.create! valid_attributes
    financial_provider.alternatives << financial_alternative
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
  
  it "renders edit financial alternative form" do
    
    assert_select "form[id=?]", "edit_financial_provider_#{@financial_provider.id}" do

      assert_select "select#financial_provider_alternative_0_alternative_type[name=?]",
                    "financial_provider[alternative_0][alternative_type]"
      
      assert_select "select#alternative_owner_0[name=?]",
                    "financial_provider[alternative_0][owner_id]"
      
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
