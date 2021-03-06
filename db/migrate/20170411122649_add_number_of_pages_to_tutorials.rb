class AddNumberOfPagesToTutorials < ActiveRecord::Migration
  def change
    add_column :tutorials, :number_of_pages, :integer
    Tutorial.reset_column_information
    Tutorial.find(1).update_attribute(:number_of_pages, 3) # Insurance
    Tutorial.find(2).update_attribute(:number_of_pages, 1) # Home
    Tutorial.find(3).update_attribute(:number_of_pages, 1) # Add Primary Contact
    Tutorial.find(4).update_attribute(:number_of_pages, 4)
  end
end
