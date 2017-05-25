class AddDescriptionToTutorials < ActiveRecord::Migration
  def change
    unless column_exists? :tutorials, :description
      add_column :tutorials, :description, :string
      Tutorial.reset_column_information
    end
    
    if column_exists? :tutorials, :slug
      remove_column :tutorials, :slug
      Tutorial.reset_column_information
    end
  end
end
