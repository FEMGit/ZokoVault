class CreateFinalWishes < ActiveRecord::Migration
  def change
    create_table :final_wishes do |t|
      t.integer :document_id
      t.integer :user_id
      t.integer :primary_contact_id
      t.string :notes
      t.string :group

      t.timestamps null: false
    end
  end
end
