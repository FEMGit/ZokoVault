class CreateTaxes < ActiveRecord::Migration
  def change
    create_table :taxes do |t|
      t.integer :document_id
      t.integer :tax_preparer_id
      t.string :notes
      t.integer :user_id
      t.integer :tax_year

      t.timestamps null: false
    end
  end
end
