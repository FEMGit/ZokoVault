require 'rails_helper'

RSpec.describe "power_of_attorneys/edit", type: :view do
  
  let(:contacts) { Array.new(3) { create(:contact, user_id: user.id) } }
  let(:document) { create(:document) }
  let(:user) { create :user }
  let(:powers) { Hash[PowerOfAttorney::POWERS.sample(3).zip([true,true,true])] }
  
  let(:power_of_attorney_contact_valid) do
    {
      user_id: user.id,
      contact_id: contacts[0].id,
      share_with_contact_ids: contacts.map(&:id)
    }
  end
  
  let(:agent_valid) do
    {
      user_id: user.id,
      powers: powers,
      agent_ids: contacts[0].id,
      notes: 'Notes',
      document_id: document.id
    }
  end
  
  before(:each) do
    power_of_attorney = PowerOfAttorney.create! agent_valid
    power_of_attorney_contact = PowerOfAttorneyContact.create! power_of_attorney_contact_valid
    
    power_of_attorney_contact.power_of_attorneys << power_of_attorney
    @power_of_attorney_contact = assign(:power_of_attorney_contact, power_of_attorney_contact)
    render
  end

  it "renders edit power of attorney for field" do

    assert_select "form[id=?][method=?]", "edit_power_of_attorney_contact_#{@power_of_attorney_contact.id}", "post" do

      assert_select "select#power_of_attorney_for_id[name=?]", "power_of_attorney_contact[contact_id]"

    end
  end
  
  it "renders edit power of attorney agent form" do
    
    assert_select "form[id=?][method=?]", "edit_power_of_attorney_contact_#{@power_of_attorney_contact.id}", "post" do

      assert_select "select#attorney_agent_id_0[name=?]", "power_of_attorney_contact[vault_entry_0][agent_ids]"
      
      assert_select "input#power_of_attorney_contact_vault_entry_0_powers_Digital[name=?]",
        "power_of_attorney_contact[vault_entry_0][powers][Digital]"
      
      assert_select "input#power_of_attorney_contact_vault_entry_0_powers_Financial[name=?]",
        "power_of_attorney_contact[vault_entry_0][powers][Financial]"
      
      assert_select "input#power_of_attorney_contact_vault_entry_0_powers_Healthcare[name=?]",
        "power_of_attorney_contact[vault_entry_0][powers][Healthcare]"
      
      assert_select "input#power_of_attorney_contact_vault_entry_0_powers_General[name=?]",
        "power_of_attorney_contact[vault_entry_0][powers][General]"
      
      assert_select "input#power_of_attorney_contact_vault_entry_0_powers_Limited[name=?]",
        "power_of_attorney_contact[vault_entry_0][powers][Limited]"
      
      assert_select "input#power_of_attorney_contact_vault_entry_0_powers_Durable[name=?]",
        "power_of_attorney_contact[vault_entry_0][powers][Durable]"
      
      assert_select "input#power_of_attorney_contact_vault_entry_0_powers_Springing[name=?]",
        "power_of_attorney_contact[vault_entry_0][powers][Springing]"
      
      assert_select "textarea#attorney_notes_id_0[name=?]", "power_of_attorney_contact[vault_entry_0][notes]"
    end
  end
  
  it "renders edit power of attorney shared with section" do

    assert_select "form[id=?][method=?]", "edit_power_of_attorney_contact_#{@power_of_attorney_contact.id}", "post" do

      assert_select "select#power_attorney_shared_id[name=?]", "power_of_attorney_contact[share_with_contact_ids][]"

    end
  end
end
