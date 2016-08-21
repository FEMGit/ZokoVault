class AddGroupToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :group, :string
  end
end
