class CreateCorporateAccountProfile < ActiveRecord::Migration
  def change
    create_table :corporate_account_profiles do |t|
      t.references :user, index: true
      t.string :business_name
      t.string :web_address
      t.string :street_address
      t.string :city
      t.string :zip
      t.string :state
      t.string :phone_number
      t.string :fax_number
      t.string :company_logo
      
      t.timestamps null: false
    end
  end
end
