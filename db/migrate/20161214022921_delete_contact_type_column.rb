class DeleteContactTypeColumn < ActiveRecord::Migration
  def change
    remove_column :shares, :contact_type
  end
end
