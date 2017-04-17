class CreatePowerOfAttorneyContact < ActiveRecord::Migration
  def change
    create_table :power_of_attorney_contacts do |t|
      t.integer :contact_id
      t.references :category, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
            
      t.timestamps null: false
    end
  end
end
