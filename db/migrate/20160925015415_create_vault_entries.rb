class CreateVaultEntries < ActiveRecord::Migration
  def change
    create_table :vault_entries do |t|
      t.integer :user_id, foreign_key: {on_delete: :cascade}
      t.integer :document_id, foreign_key: {on_delete: :cascade}
      t.integer :executor_id, foreign_key: {on_delete: :cascade}

      t.timestamps null: false
    end
  end
end
