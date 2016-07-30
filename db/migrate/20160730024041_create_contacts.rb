class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :firstname
      t.string :lastname
      t.string :emailaddress
      t.string :phone
      t.string :category
      t.string :relationship
      t.string :beneficiarytype
      t.string :ssn
      t.date :birthdate
      t.string :address
      t.string :zipcode
      t.string :state
      t.text :notes
      t.string :avatarcolor
      t.string :photourl
      t.string :businessname
      t.string :businesswebaddress
      t.string :businessphone
      t.string :businessfax

      t.timestamps null: false
    end
  end
end
