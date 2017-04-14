require 'rails_helper'

RSpec.describe "trusts/edit", type: :view do
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:document) { create :document }
  let(:user) { create :user }

  let(:valid_attributes) do
    {
      name: "Trust",
      user_id: user.id,
      trustee_ids: contacts.first(2).map(&:id),
      successor_trustee_ids: contacts.last(1).map(&:id),
      agent_ids: contacts.first(2).map(&:id),
      share_with_contact_ids: contacts.map(&:id),
      document_id: document.id
    }
  end
  
  before(:each) do
    @trust = Trust.create! valid_attributes
    @vault_entry = @trust
    @vault_entries = Array.wrap(@vault_entry)
    render
  end

  it "renders new trusts entities form" do
    assert_select "form[id=?][method=?]", "edit_trust_#{@trust.id}", "post" do

      assert_select "input#vault_entry_0_name[name=?]", "vault_entry_0[name]"
      
      assert_select "select#trust_agent_id_0[name=?]", "vault_entry_0[agent_ids][]"
      
      assert_select "select#trust_trustee_id_0[name=?]", "vault_entry_0[trustee_ids][]"
      
      assert_select "select#trust_successor_id_0[name=?]", "vault_entry_0[successor_trustee_ids][]"
      
      assert_select "textarea#trust_notes_id_0[name?]", "vault_entry_0[notes]"
      
      assert_select "select#trust_share_id_0[name=?]", "vault_entry_0[share_with_contact_ids][]"
      
    end
  end
end