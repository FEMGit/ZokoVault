class RenameToDoPopupCancelsTable < ActiveRecord::Migration
  def change
    rename_table :to_do_popup_cancels, :to_do_cancels
  end
end
