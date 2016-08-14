class ChangeNameFormatInVendor < ActiveRecord::Migration
  def self.up
    change_column :vendors, :category, :string
    change_column :vendors, :group, :string
    change_column :vendors, :name, :string
    change_column :vendors, :webaddress, :string
    change_column :vendors, :phone, :string
  end

  def self.down
    change_column :vendors, :category, :text
    change_column :vendors, :group, :text
    change_column :vendors, :name, :text
    change_column :vendors, :webaddress, :text
    change_column :vendors, :phone, :text
  end
end
