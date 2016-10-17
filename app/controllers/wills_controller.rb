class WillsController < AuthenticatedController
  def new
    @vault_entry = VaultEntryBuilder.new.build
    @vault_entry.vault_entry_contacts.build
    @vault_entry.vault_entry_beneficiaries.build
  end
  
  def details
  end
end
