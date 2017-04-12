class AddNumberOfPagesToTutorials < ActiveRecord::Migration
  def change
    add_column :tutorials, :number_of_pages, :integer
    Tutorial.find(1).update_attribute(:number_of_pages, 3)
    Tutorial.find(2).update_attribute(:number_of_pages, 1)
    Tutorial.find(3).update_attribute(:number_of_pages, 3)
    Tutorial.find(4).update_attribute(:number_of_pages, 4)
  end
end
