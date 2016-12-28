class CreateFinancialInvestments < ActiveRecord::Migration
  def change
    create_table :financial_investments do |t|
      t.string :name
      t.integer :investment_type
      t.integer :owner_id
      t.decimal :value
      t.string :web_address
      t.string :phone_number
      t.string :address
      t.string :city
      t.string :state
      t.integer :zip
      t.integer :primary_contact_id
      t.integer :notes
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
