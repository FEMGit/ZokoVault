require 'rails_helper'

RSpec.describe "trusts/new", type: :view do
  let(:user) { create :user }
  
  before(:each) do
    @vault_entry = TrustBuilder.new(type: 'trust').build
    @vault_entry.user = user
    @vault_entries = [@vault_entry]
    render
  end
  
  it "renders new trusts entities form" do
    assert_select "form[id=?][method=?]", "new_trust", "post" do

      assert_select "input#vault_entry_0_name[name=?]", "vault_entry_0[name]"
      
      assert_select "select#trust_agent_id_0[name=?]", "vault_entry_0[agent_ids][]"
      
      assert_select "select#trust_trustee_id_0[name=?]", "vault_entry_0[trustee_ids][]"
      
      assert_select "select#trust_successor_id_0[name=?]", "vault_entry_0[successor_trustee_ids][]"
      
      assert_select "textarea#trust_notes_id_0[name?]", "vault_entry_0[notes]"
      
      assert_select "select#trust_share_id_0[name=?]", "vault_entry_0[share_with_contact_ids][]"
      
    end
  end
end