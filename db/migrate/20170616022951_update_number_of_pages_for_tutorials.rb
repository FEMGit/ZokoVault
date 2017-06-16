class UpdateNumberOfPagesForTutorials < ActiveRecord::Migration
  def change
    tutorial = Tutorial.find_by(:name => "My Family") || Tutorial.find_by(:name => "I have a family.")
    tutorial.update(:number_of_pages => 1)
  end
end
