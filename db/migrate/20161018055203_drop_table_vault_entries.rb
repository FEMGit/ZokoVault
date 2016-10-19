class DropTableVaultEntries < ActiveRecord::Migration
  def change
    drop_table :vault_entries
  end
end
