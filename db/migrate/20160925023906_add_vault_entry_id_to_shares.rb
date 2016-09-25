class AddVaultEntryIdToShares < ActiveRecord::Migration
  def change
    add_column :shares, :vault_entry_id, :integer
  end
end
