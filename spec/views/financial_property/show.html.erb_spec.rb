require 'rails_helper'

RSpec.describe "financial_property/show", type: :view do
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Property Name",
      property_type: "Commercial",
      notes: "Notes",
      value: 1000,
      address: "Address",
      city: "City",
      state: "IL",
      zip: 55555,
      primary_contact_id: contacts.first.id,
      share_with_contacts: contacts,
      user_id: user.id
    }
  end
  
  let(:provider_attributes) do 
    {
      name: "Property Name",
      provider_type: 'Property',
      user_id: user.id,
      share_with_contacts: contacts
    }
  end
  
  before(:each) do
    financial_property = FinancialProperty.create! valid_attributes
    financial_property.property_owner_ids = (AccountPolicyOwner.create contact_id: contacts.first.id, contactable_id: financial_property.id,
                                                                       contactable_type: financial_property.class).id

    financial_provider = FinancialProvider.create! provider_attributes
    financial_provider.properties << financial_property
    assign(:financial_property, financial_property)
    assign(:property_provider, financial_provider)
    
    render
  end

  it "displays financial property correctly" do
    expect(rendered).to match(/Property Name/)
    expect(rendered).to match(/Commercial/)
    expect(rendered).to match(/Notes/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/City/)
    expect(rendered).to match(/IL/)
    expect(rendered).to match(/\$1,000/)
    expect(rendered).to match(/55555/)
  end
  
  it "displays financial property primary contact correctly" do
    expect(rendered).to match(/#{contacts.first.name}/)
    expect(rendered).to match(/#{contacts.first.emailaddress}/)
    expect(rendered).to match(/#{contacts.first.phone}/)
  end
  
  it "displays financial property shared with correctly" do
    contacts.each do |contact|
     expect(rendered).to match(/#{contact.initials}/)
     expect(rendered).to match(/#{contact.emailaddress}/)
     expect(rendered).to match(/#{contact.phone}/)
    end
  end
end