class UpdateDocumentsTable < ActiveRecord::Migration
  def change
    rename_column :documents, :vault_entry_id, :card_document_id
  end
end