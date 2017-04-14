require 'rails_helper'

RSpec.describe "power_of_attorneys/new_wills_poa", type: :view do
  let(:user) { create :user }
  
  before(:each) do
    @power_of_attorney = PowerOfAttorneyBuilder.new.build
    @power_of_attorney.user = user
    @power_of_attorney.vault_entry_contacts.build

    @power_of_attorney_contact = PowerOfAttorneyContact.new(user: user,
      category: Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase))
    @power_of_attorney_contact.power_of_attorneys << @power_of_attorney
    render
  end

  it "renders edit power of attorney for field" do

    assert_select "form[id=?][method=?]", "new_power_of_attorney_contact", "post" do

      assert_select "select#power_of_attorney_for_id[name=?]", "power_of_attorney_contact[contact_id]"

    end
  end
  
  it "renders edit power of attorney agent form" do
    
    assert_select "form[id=?][method=?]", "new_power_of_attorney_contact", "post" do

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

    assert_select "form[id=?][method=?]", "new_power_of_attorney_contact", "post" do

      assert_select "select#power_attorney_shared_id[name=?]", "power_of_attorney_contact[share_with_contact_ids][]"

    end
  end
end
