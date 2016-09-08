class RenameCategoryToContactTypeOnContacts < ActiveRecord::Migration
  def change
    rename_column :contacts, :category, :contact_type
  end
end
