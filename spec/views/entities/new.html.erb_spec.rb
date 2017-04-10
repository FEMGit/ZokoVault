require 'rails_helper'

RSpec.describe "entities/new", type: :view do
  before(:each) do
    entity = Entity.new
    assign(:entity, entity)
    
    render
  end

  it "renders new entity form" do
    assert_select "form[id=?][method=?]", "new_entity", "post" do

      assert_select "input#entity_name[name=?]", "entity[name]"
      
      assert_select "select#entity_agent_ids[name=?]", "entity[agent_ids][]"
      
      assert_select "select#entity_partner_ids[name=?]", "entity[partner_ids][]"
      
      assert_select "textarea#entity_notes[name=?]", "entity[notes]"
      
      assert_select "select#entity_share_with_contact_ids[name=?]", "entity[share_with_contact_ids][]"
    end
  end
end
