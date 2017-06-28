class AddCorporateContactBooleanToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :corporate_contact, :boolean, :default => false
  end
end
