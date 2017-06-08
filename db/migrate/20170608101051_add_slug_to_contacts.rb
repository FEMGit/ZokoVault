class AddSlugToContacts < ActiveRecord::Migration
  def change
    unless column_exists? :contacts, :slug
      add_column :contacts, :slug, :string, :unique => true
      Contact.reset_column_information
    end
  end
end
