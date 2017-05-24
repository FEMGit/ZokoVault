class AddNumberOfPagesToSubtutorials < ActiveRecord::Migration
  def change
    unless column_exists? :subtutorials, :number_of_pages
      add_column :subtutorials, :number_of_pages, :integer, :default => 1
      Subtutorial.reset_column_information
    end
    
    Subtutorial.find_by(:short_name => 'estate-attorney').update(number_of_pages: 3)
  end
end
