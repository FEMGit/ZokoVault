class AddBusinessStreetAddressToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :business_street_address, :string
  end
end
