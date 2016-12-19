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
    assign(:financial_investment, financial_investment)
    
    render
  end

  it "displays financial investment correctly" do
    expect(rendered).to match(/Investment Name/)
    expect(rendered).to match(/www.zokuvault.com/)
    expect(rendered).to match(/Private Company Stock/)
    expect(rendered).to match(/Notes/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/City/)
    expect(rendered).to match(/State/)
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
      expect(rendered).to match(/#{contact.name}/)
      expect(rendered).to match(/#{contact.emailaddress}/)
      expect(rendered).to match(/#{contact.phone}/)
    end
  end
end
