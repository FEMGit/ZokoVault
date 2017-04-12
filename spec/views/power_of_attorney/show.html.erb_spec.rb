require 'rails_helper'

RSpec.describe "power_of_attorneys/show", type: :view do
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:user) { create :user }
  let(:powers) { Hash[PowerOfAttorney::POWERS.sample(3).zip([true,true,true])] }
  
  let(:agent_valid) do
    {
      user_id: user.id,
      powers: powers,
      agent_ids: contacts[0].id,
      notes: 'Notes'
    }
  end
  
  let(:power_of_attorney_contact_valid) do
    {
      user_id: user.id,
      contact_id: contacts[0].id,
      share_with_contacts: contacts
    }
  end
  
  before(:each) do
    power_of_attorney_contact = PowerOfAttorneyContact.create! power_of_attorney_contact_valid
    power_of_attorney = PowerOfAttorney.create! agent_valid
    power_of_attorney_contact.power_of_attorneys = [power_of_attorney]
    assign(:power_of_attorney_contact, power_of_attorney_contact)
    
    render
  end

  it "displays PoA For name correctly" do
    expect(rendered).to match(/#{contacts[0].name}/)
  end
  
  it "displays agent information correctly" do
    powers.each do |power|
     expect(rendered).to match(/#{power}/)
     expect(rendered).to match(/#{contacts[0].name}/)
      expect(rendered).to match(/Notes/)
    end
  end
  
  it "displays shared with section correctly" do
    contacts.each do |contact|
     expect(rendered).to match(/#{contact.name}/)
     expect(rendered).to match(/#{contact.emailaddress}/)
     expect(rendered).to match(/#{contact.phone}/)
    end
  end
end
