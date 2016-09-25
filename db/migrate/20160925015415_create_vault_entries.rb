class CreateVaultEntries < ActiveRecord::Migration
  def change
    create_table :vault_entries do |t|
      t.references :user, foreign_key: true

      t.timestamps null: false
    end
  end
end
