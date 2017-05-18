class AddDescriptionToTutorials < ActiveRecord::Migration
  def change
    add_column :tutorials, :description, :string
    remove_column :tutorials, :slug
  end
end
