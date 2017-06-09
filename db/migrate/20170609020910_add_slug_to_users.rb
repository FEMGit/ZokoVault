class AddSlugToUsers < ActiveRecord::Migration
  def change
    unless column_exists? :users, :slug
      add_column :users, :slug, :string, :unique => true
      User.reset_column_information
    end
  end
end
