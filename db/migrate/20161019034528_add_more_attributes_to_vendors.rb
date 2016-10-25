class AddMoreAttributesToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :fax, :string
    add_column :vendors, :street_address_1, :string
    add_column :vendors, :street_address_2, :string
    add_column :vendors, :city, :string
    add_column :vendors, :state, :string
    add_column :vendors, :zip, :string
    add_column :vendors, :type, :string
  end
end
