class AddCorporateActivatedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :corporate_activated, :boolean, :default => false
  end
end
