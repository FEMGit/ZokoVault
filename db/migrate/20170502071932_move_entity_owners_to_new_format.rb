class MoveEntityOwnersToNewFormat < ActiveRecord::Migration
  def change
    entity_contacts = VaultEntryContact.where(contactable_type: 'Entity', type: VaultEntryContact.types[:partner]).select(&:contact_id)
    entity_contacts.to_a.each do |entity_contact|
      AccountPolicyOwner.create(contact_id: entity_contact.contact_id, contactable_id: entity_contact.contactable_id, contactable_type: 'Entity')
    end
  end
end
