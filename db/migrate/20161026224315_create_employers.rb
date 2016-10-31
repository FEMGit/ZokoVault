class CreateEmployers < ActiveRecord::Migration
  def change
    create_table :employers do |t|
      t.integer :user_profile_id
      t.string :name
      t.string :web_address
      t.string :street_address_1
      t.string :street_address_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone_number_office
      t.string :phone_number_fax
      t.string :notes

      t.timestamps null: false
    end
  end
end
