class AssociateBenficiariesWithWills < ActiveRecord::Migration
  def change
    rename_column :vault_entry_beneficiaries, :vault_entry_id, :will_id
  end
end
