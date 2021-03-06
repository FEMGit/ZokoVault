
require 'rails_helper'

RSpec.describe "financial_investment/show", type: :view do
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Investment Name",
      web_address: "www.zokuvault.com",
      investment_type: "Private Company Stock",
      notes: "Notes",
      value: "100",
      address: "Address",
      city: "City",
      state: "IL",
      zip: 55555,
      phone_number: "777-777-7777",
      primary_contact_id: contacts.first.id,
      share_with_contacts: contacts,
      user_id: user.id
    }
  end
  

  let(:provider_attributes) do 
    {
      name: "Investment Name",
      provider_type: "Investment",
      share_with_contacts: contacts,
      user_id: user.id
    }
  end
  
  before(:each) do
    financial_investment = FinancialInvestment.create! valid_attributes
    financial_investment.owner_ids = (AccountPolicyOwner.create contact_id: contacts.first.id, contactable_id: financial_investment.id,
                                                                       contactable_type: financial_investment.class).id
    financial_provider = FinancialProvider.create! provider_attributes
    financial_provider.investments << financial_investment
    assign(:financial_investment, financial_investment)
    assign(:investment_provider, financial_provider)
    
    render
  end

  it "displays financial investment correctly" do
    expect(rendered).to match(/Investment Name/)
    expect(rendered).to match(/www.zokuvault.com/)
    expect(rendered).to match(/Private Company Stock/)
    expect(rendered).to match(/Notes/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/City/)
    expect(rendered).to match(/IL/)
    expect(rendered).to match(/\$100/)
    expect(rendered).to match(/55555/)
    expect(rendered).to match(/777-777-7777/)
  end
  
  it "displays financial investment primary contact correctly" do
    expect(rendered).to match(/#{contacts.first.name}/)
    expect(rendered).to match(/#{contacts.first.emailaddress}/)
    expect(rendered).to match(/#{contacts.first.phone}/)
  end
  
  it "displays financial investment shared with correctly" do
    contacts.each do |contact|
     expect(rendered).to match(/#{contact.initials}/)
     expect(rendered).to match(/#{contact.emailaddress}/)
     expect(rendered).to match(/#{contact.phone}/)
    end
  end
end