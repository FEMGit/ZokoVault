class CreateFinancialAccountProviders < ActiveRecord::Migration
  def change
    create_table :financial_account_providers do |t|
      t.string :name
      t.string :web_address
      t.string :street_address
      t.string :city
      t.string :state
      t.integer :zip
      t.string :phone_number
      t.string :fax_number
      t.integer :primary_contact
      t.integer :account_information_id

      t.timestamps null: false
    end
  end
end
