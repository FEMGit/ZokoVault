class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.references :user, index: true
      t.references :folder, index: true
      t.string :name, null: false
      t.text :description
      t.string :url, null: false

      t.timestamps null: false
    end
  end
end
