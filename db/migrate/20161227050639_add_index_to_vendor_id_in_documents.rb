class AddIndexToVendorIdInDocuments < ActiveRecord::Migration
  def change
    add_index :documents, :vendor_id
  end
end
