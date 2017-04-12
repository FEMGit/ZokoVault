class CreateCardDocuments < ActiveRecord::Migration
  def change
    create_table :card_documents do |t|
      t.integer :card_id
      t.references :user, index: true, foreign_key: true
      t.string :object_type
      t.integer :category_id

      t.timestamps null: false
    end
  end
end