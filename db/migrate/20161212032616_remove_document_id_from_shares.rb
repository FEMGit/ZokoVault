class RemoveDocumentIdFromShares < ActiveRecord::Migration
  def change
    remove_column :shares, :document_id, :integer
  end
end
