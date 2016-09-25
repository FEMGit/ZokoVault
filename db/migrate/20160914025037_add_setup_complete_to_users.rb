class AddSetupCompleteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :setup_complete, :boolean, default: false
  end
end
