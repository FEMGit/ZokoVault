class WtlBaseController < AuthenticatedController
  before_action :set_category, :set_group, :set_ret_url
  
  def set_category
    @category = "Wills - Trusts - Legal"
  end

  def new
    @vault_entry = VaultEntryBuilder.new.build
    @vault_entry.vault_entry_contacts.build
    @vault_entry.vault_entry_beneficiaries.build
  end

  def details
    @group_documents = Document.for_user(current_user).where(category: @category, group: @group)
  end
end