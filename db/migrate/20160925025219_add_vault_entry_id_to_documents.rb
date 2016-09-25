class AddVaultEntryIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :vault_entry_id, :integer
  end
end
