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
      owner_id: contacts.first.id,
      address: "Address",
      city: "City",
      state: "State",
      zip: 55555,
      primary_contact_id: contacts.first.id,
      share_with_contact_ids: contacts.map(&:id),
      user_id: user.id
    }
  end
  
  before(:each) do
    financial_property = FinancialProperty.create! valid_attributes
    assign(:financial_property, financial_property)
    
    render
  end

  it "displays financial property correctly" do
    expect(rendered).to match(/Property Name/)
    expect(rendered).to match(/Commercial/)
    expect(rendered).to match(/Notes/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/City/)
    expect(rendered).to match(/State/)
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
      expect(rendered).to match(/#{contact.name}/)
      expect(rendered).to match(/#{contact.emailaddress}/)
      expect(rendered).to match(/#{contact.phone}/)
    end
  end
end
