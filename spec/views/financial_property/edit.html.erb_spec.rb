require 'rails_helper'

RSpec.describe "financial_property/new", type: :view do
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Property Name",
      property_type: "Commercial",
      notes: "Notes",
      value: 99.99,
      address: "Address",
      city: "City",
      state: "IL",
      zip: 55555,
      primary_contact_id: contacts.first.id,
      share_with_contact_ids: contacts.map(&:id),
      user_id: user.id
    }
  end
  
  before(:each) do
    financial_property = FinancialProperty.create! valid_attributes
    financial_property.property_owner_ids = (AccountPolicyOwner.create contact_id: contacts.first.id, contactable_id: financial_property.id,
                                                                       contactable_type: financial_property.class).id
    @financial_property = assign(:financial_property, financial_property)
    @account_owners = contacts.collect { |s| [s.id.to_s + '_contact', s.name, class: "contact-item"] }
    render
  end

  it "renders edit financial property form" do
    assert_select "form[id=?][method=?]", "edit_financial_property_#{@financial_property.id}", "post" do

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
