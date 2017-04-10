require 'rails_helper'

RSpec.describe "wills/edit", type: :view do
  
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:primary_contact_broker) { create(:contact, user_id: user.id) }
  
  let(:user) { create :user }
  
  let(:valid_attributes) do
    {
      title: "Title",
      user_id: user.id,
      primary_beneficiary_ids: contacts.first(2).map(&:id),
      secondary_beneficiary_ids: contacts.last(1).map(&:id),
      executor_id: contacts[1].id,
      agent_ids: contacts[0].id,
      share_with_contact_ids: contacts.map(&:id)
    }
  end
  
  before(:each) do
    @will = Will.create! valid_attributes
    @vault_entry = @will
    @vault_entries = Array.wrap(@vault_entry)
    render
  end

  it "renders edit financial provider form" do
    assert_select "form[id=?][method=?]", "edit_will_#{@will.id}", "post" do

      assert_select "input#will_title_id_0[name=?]", "vault_entry_0[title]"
      
      assert_select "select#will_executor_id_0[name=?]", "vault_entry_0[executor_id]"
      
      assert_select "select#will_primary_id_0[name=?]", "vault_entry_0[primary_beneficiary_ids][]"
      
      assert_select "select#will_secondary_id_0[name=?]", "vault_entry_0[secondary_beneficiary_ids][]"
      
      assert_select "select#will_agent_id_0[name=?]", "vault_entry_0[agent_ids]"
      
      assert_select "textarea#will_notes_id_0[name?]", "vault_entry_0[notes]"
      
      assert_select "select#will_share_id_0[name=?]", "vault_entry_0[share_with_contact_ids][]"
      
    end
  end
end
