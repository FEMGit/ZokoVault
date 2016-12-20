class AddEmailaddressIndexOnContacts < ActiveRecord::Migration
  def change
    add_index :contacts, :emailaddress
  end
end
