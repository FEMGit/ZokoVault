class RemoveNamesFromTutorials < ActiveRecord::Migration
  def change
    if column_exists? :subtutorials, :short_name
      remove_column :subtutorials, :short_name
      Subtutorial.reset_column_information
    end
    
    if column_exists? :tutorials, :content
      remove_column :tutorials, :content
      Tutorial.reset_column_information
    end
    
    Tutorial.all.each do |tutorial|
      tutorial.update(name: tutorial.description)
    end
    
    remove_column :tutorials, :description
    Tutorial.reset_column_information
  end
end
