class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.integer :document_id
      t.integer :contact_id
      t.string :permission

      t.timestamps null: false
    end
  end
end
