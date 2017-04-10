require 'rails_helper'

RSpec.describe "entities/new", type: :view do
  let(:agent_contacts) { Array.new(2) { create(:contact, user_id: user.id) } }
  let(:partner_contacts) { Array.new(2) { create(:contact, user_id: user.id) } }
  let(:share_contacts) { Array.new(2) { create(:contact, user_id: user.id) } }
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Entity name",
      user_id: user.id,
      notes: 'Notes',
      agent_ids: agent_contacts.map(&:id),
      partner_ids: partner_contacts.map(&:id),
      share_with_contact_ids: share_contacts.map(&:id)
    }
  end
  
  before(:each) do
    entity = Entity.create! valid_attributes
    @entity = assign(:entity, entity)
    
    render
  end

  it "renders edit entity form" do
    assert_select "form[id=?][method=?]", "edit_entity_#{@entity.id}", "post" do

      assert_select "input#entity_name[name=?]", "entity[name]"
      
      assert_select "select#entity_agent_ids[name=?]", "entity[agent_ids][]"
      
      assert_select "select#entity_partner_ids[name=?]", "entity[partner_ids][]"
      
      assert_select "textarea#entity_notes[name=?]", "entity[notes]"
      
      assert_select "select#entity_share_with_contact_ids[name=?]", "entity[share_with_contact_ids][]"
    end
  end
end
