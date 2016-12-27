class AddGroupIdToHealth < ActiveRecord::Migration
  def change
    add_column :health_policies, :group_id, :string
  end
end
