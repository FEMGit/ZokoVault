require 'rails_helper'

RSpec.describe "trusts/show", type: :view do
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Trust",
      user_id: user.id,
      trustee_ids: contacts.first(2).map(&:id),
      successor_trustee_ids: contacts.last(1).map(&:id),
      agent_ids: contacts.last(2).map(&:id),
      share_with_contacts: contacts
    }
  end
  
  before(:each) do
    trust = Trust.create! valid_attributes
    assign(:trust, trust)
    
    render
  end

  it "displays trust name correctly" do
    expect(rendered).to match(/Trust/)
  end
  
  it "displays trustees correctly" do
    contacts.first(2).each do |contact|
     expect(rendered).to match(/#{contact.initials}/)
     expect(rendered).to match(/#{contact.emailaddress}/)
     expect(rendered).to match(/#{contact.phone}/)
    end
  end
  
  it "displays successor trustees correctly" do
    contacts.last(1).each do |contact|
     expect(rendered).to match(/#{contact.initials}/)
     expect(rendered).to match(/#{contact.emailaddress}/)
     expect(rendered).to match(/#{contact.phone}/)
    end
  end
  
  it "displays agents correctly" do
    contacts.last(2).each do |contact|
     expect(rendered).to match(/#{contact.initials}/)
     expect(rendered).to match(/#{contact.emailaddress}/)
     expect(rendered).to match(/#{contact.phone}/)
    end
  end
  
  it "displays shared with contacts correctly" do
    contacts.last(2).each do |contact|
     expect(rendered).to match(/#{contact.initials}/)
     expect(rendered).to match(/#{contact.emailaddress}/)
     expect(rendered).to match(/#{contact.phone}/)
    end
  end
end
