class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.text :category
      t.text :group
      t.text :name
      t.text :webaddress
      t.text :phone
      t.references :contact, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
