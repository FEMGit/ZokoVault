require 'rails_helper'

RSpec.describe "financial_alternative/show", type: :view do
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
      commitment: "100",
      total_calls: "101",
      total_distributions: "102",
      current_value: "103",
      primary_contact_id: primary_contact.id,
      notes: "Notes",
      user_id: user.id
    }
  end
  
  before(:each) do
    financial_alternative = FinancialAlternative.create! alternative_0
    financial_provider = FinancialProvider.create! valid_attributes
    financial_provider.alternatives << financial_alternative
    assign(:financial_provider, financial_provider)
    
    render
  end

  it "displays financial provider correctly" do
    expect(rendered).to match(/Provider Name/)
    expect(rendered).to match(/www.zokuvault.com/)
    expect(rendered).to match(/Street/)
    expect(rendered).to match(/City/)
    expect(rendered).to match(/State/)
    expect(rendered).to match(/55555/)
    expect(rendered).to match(/777-777-7777/)
    expect(rendered).to match(/888-888-8888/)
  end
  
  it "displays financial provider primary contact correctly" do
    expect(rendered).to match(/#{contacts.first.name}/)
    expect(rendered).to match(/#{contacts.first.emailaddress}/)
    expect(rendered).to match(/#{contacts.first.phone}/)
  end
  
  it "displays financial provider shared with correctly" do
    contacts.each do |contact|
      expect(rendered).to match(/#{contact.name}/)
      expect(rendered).to match(/#{contact.emailaddress}/)
      expect(rendered).to match(/#{contact.phone}/)
    end
  end
  
  it "displays financial alternative correctly" do
    expect(rendered).to match(/Venture Capital/)
    expect(rendered).to match(/Notes/)
    expect(rendered).to match(/Investment Name/)
    expect(rendered).to match(/\$100/)
    expect(rendered).to match(/\$101/)
    expect(rendered).to match(/\$102/)
    expect(rendered).to match(/\$103/)
  end
  
  it "displays financial alternative primary contact correctly" do
    expect(rendered).to match(/#{primary_contact.name}/)
    expect(rendered).to match(/#{primary_contact.emailaddress}/)
    expect(rendered).to match(/#{primary_contact.phone}/)
  end
end
