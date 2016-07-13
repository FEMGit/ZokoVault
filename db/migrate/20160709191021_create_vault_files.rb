class CreateVaultFiles < ActiveRecord::Migration
  def change
    create_table :vault_files do |t|
      t.string :name
      t.text :description
      t.string :folder
      t.string :url
    end
  end
end
