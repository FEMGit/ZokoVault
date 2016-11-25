class AddNotesToWtl < ActiveRecord::Migration
  def change
    add_column :wills, :notes, :string
    add_column :trusts, :notes, :string
    add_column :power_of_attorneys, :notes, :string
  end
end
