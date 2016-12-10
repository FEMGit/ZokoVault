class ChangeColumnTypeAndName < ActiveRecord::Migration
  def change
    change_column :final_wishes, :group, 'integer USING CAST("group" AS integer)'
    rename_column :final_wishes, :group, :final_wish_info_id
  end
end