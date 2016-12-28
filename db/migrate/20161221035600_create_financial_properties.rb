class CreateFinancialProperties < ActiveRecord::Migration
  def change
    create_table :financial_properties do |t|
      t.string :name
      t.string :type
      t.integer :owner_id
      t.decimal :value
      t.string :address
      t.string :city
      t.string :state
      t.integer :zip
      t.integer :primary_contact_id
      t.string :notes

      t.timestamps null: false
    end
  end
end
