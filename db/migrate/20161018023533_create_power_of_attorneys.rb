class CreatePowerOfAttorneys < ActiveRecord::Migration
  def change
    create_table :power_of_attorneys do |t|
      enable_extension "hstore"

      t.integer :document_id
      t.integer :power_of_attorney_id
      t.hstore :powers
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
