class AddSlugToVendors < ActiveRecord::Migration
  def change
    unless column_exists? :vendors, :slug
      add_column :vendors, :slug, :string, :unique => true
      Vendor.reset_column_information
    end
  end
end
