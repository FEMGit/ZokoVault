require 'rails_helper'

RSpec.describe "wills/new", type: :view do
  let(:user) { create :user }
  
  before(:each) do
    @vault_entry = WillBuilder.new(type: 'will').build
    @vault_entry.user = user
    @vault_entry.vault_entry_contacts.build
    @vault_entry.vault_entry_beneficiaries.build
    @vault_entries = []
    @vault_entries << @vault_entry
    render
  end

  it "renders new wills poa form" do
    assert_select "form[id=?][method=?]", "new_will", "post" do

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
