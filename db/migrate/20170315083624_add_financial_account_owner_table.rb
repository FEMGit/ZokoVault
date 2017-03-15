class AddFinancialAccountOwnerTable < ActiveRecord::Migration
  def change
    create_table :financial_account_owners do |t|
      t.references :contact, index: true, foreign_key: {on_delete: :cascade}
      t.integer :contactable_id
      t.string :contactable_type

      t.timestamps null: false
    end
  end
end
