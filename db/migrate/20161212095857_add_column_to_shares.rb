class AddColumnToShares < ActiveRecord::Migration
  def change
    add_column :shares, :contact_type, :string
  end
end
