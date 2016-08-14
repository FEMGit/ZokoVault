class CreateVendorAccounts < ActiveRecord::Migration
  def change
    create_table :vendor_accounts do |t|
      t.string :name
      t.string :group
      t.string :category
      t.references :vendor, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
