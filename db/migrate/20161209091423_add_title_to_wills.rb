class AddTitleToWills < ActiveRecord::Migration
  def change
    add_column :wills, :title, :string
  end
end
