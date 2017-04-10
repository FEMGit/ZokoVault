require 'rails_helper'

RSpec.describe "entities/show", type: :view do
  let(:agent_contacts) { Array.new(2) { create(:contact, user_id: user.id) } }
  let(:partner_contacts) { Array.new(2) { create(:contact, user_id: user.id) } }
  let(:share_contacts) { Array.new(2) { create(:contact, user_id: user.id) } }
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Entity name",
      notes: 'Notes',
      user_id: user.id,
      agents: agent_contacts,
      partners: partner_contacts,
      share_with_contacts: share_contacts
    }
  end
  
  before(:each) do
    entity = Entity.create! valid_attributes
    @entity = assign(:entity, entity)
    
    render
  end

  it "displays entity information correctly" do
    expect(rendered).to match(/Entity name/)
    expect(rendered).to match(/Notes/)
  end
  
  it "displays entity shared with correctly" do
    share_contacts.each do |contact|
     expect(rendered).to match(/#{contact.initials}/)
     expect(rendered).to match(/#{contact.emailaddress}/)
     expect(rendered).to match(/#{contact.phone}/)
    end
  end
  
  it "displays entity agents correctly" do
    agent_contacts.each do |contact|
     expect(rendered).to match(/#{contact.name}/)
    end
  end
  
  it "displays entity partners/owners correctly" do
    partner_contacts.each do |contact|
     expect(rendered).to match(/#{contact.name}/)
    end
  end
end