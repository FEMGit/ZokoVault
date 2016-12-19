require 'rails_helper'

RSpec.describe "financial_investment/edit", type: :view do
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Investment Name",
      web_address: "www.zokuvault.com",
      investment_type: "Private Company Stock",
      notes: "Notes",
      value: "100",
      owner_id: contacts.first.id,
      address: "Address",
      city: "City",
      state: "State",
      zip: 55555,
      phone_number: "777-777-7777",
      primary_contact_id: contacts.first.id,
      share_with_contact_ids: contacts.map(&:id),
      user_id: user.id
    }
  end
  
  before(:each) do
    financial_investment = FinancialInvestment.create! valid_attributes
    @financial_investment = assign(:financial_investment, financial_investment)
    
    render
  end

  it "renders edit financial investment form" do
    
    assert_select "form[id=?][method=?]", "edit_financial_investment_#{@financial_investment.id}", "post" do

      assert_select "input#financial_investment_name[name=?]", "financial_investment[name]"
      
      assert_select "select#financial_investment_investment_type[name=?]", "financial_investment[investment_type]"
      
      assert_select "select#financial_investment_owner_id[name=?]", "financial_investment[owner_id]"
      
      assert_select "input#financial_investment_value[name=?]", "financial_investment[value]"
      
      assert_select "input#financial_investment_web_address[name=?]", "financial_investment[web_address]"
      
      assert_select "input#financial_investment_phone_number[name=?]", "financial_investment[phone_number]"
      
      assert_select "input#financial_investment_address[name=?]", "financial_investment[address]"
      
      assert_select "input#financial_investment_city[name=?]", "financial_investment[city]"
      
      assert_select "select#financial_investment_state[name=?]", "financial_investment[state]"
      
      assert_select "input#financial_investment_zip[name=?]", "financial_investment[zip]"
      
      assert_select "select#financial_investment_primary_contact_id[name=?]", "financial_investment[primary_contact_id]"
      
      assert_select "textarea#financial_investment_notes[name=?]", "financial_investment[notes]"
      
      assert_select "select#financial_investment_share_with_contact_ids[name=?]", "financial_investment[share_with_contact_ids][]"
    end
  end
end
