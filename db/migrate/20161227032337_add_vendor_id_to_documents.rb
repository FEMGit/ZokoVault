class AddVendorIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :vendor_id, :integer
  end
end
