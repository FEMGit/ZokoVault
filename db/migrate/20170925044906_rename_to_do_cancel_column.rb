class RenameToDoCancelColumn < ActiveRecord::Migration
  def change
    rename_column :to_do_cancels, :cancelled_popups, :cancelled_categories
  end
end
