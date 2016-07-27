class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.references :user, index: true
      t.references :parent, index: true
      t.string :type
      t.string :name, null: false
      t.text :description
      t.boolean :system, null: false, default: false

      t.timestamps null: false
    end
  end
end
