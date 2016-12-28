class CreateFinancialAccountInformations < ActiveRecord::Migration
  def change
    create_table :financial_account_informations do |t|
      t.string :type
      t.integer :owner
      t.decimal :value
      t.string :number
      t.integer :primary_contact_broker
      t.string :notes

      t.timestamps null: false
    end
  end
end
