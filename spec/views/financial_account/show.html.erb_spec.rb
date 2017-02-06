require 'rails_helper'

RSpec.describe "financial_account/show", type: :view do
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
  
  it "displays financial account correctly" do
    expect(rendered).to match(/Bond/)
    expect(rendered).to match(/Account Name/)
    expect(rendered).to match(/\$15,000/)
    expect(rendered).to match(/Notes/)
  end
  
  it "displays financial account primary contact correctly" do
    expect(rendered).to match(/#{primary_contact_broker.name}/)
    expect(rendered).to match(/#{primary_contact_broker.emailaddress}/)
    expect(rendered).to match(/#{primary_contact_broker.phone}/)
  end
  
  it "displays financial account shared with correctly" do
    contacts.each do |contact|
     expect(rendered).to match(/#{contact.initials}/)
     expect(rendered).to match(/#{contact.emailaddress}/)
     expect(rendered).to match(/#{contact.phone}/)
    end
  end
end
