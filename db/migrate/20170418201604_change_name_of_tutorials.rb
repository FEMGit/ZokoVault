class ChangeNameOfTutorials < ActiveRecord::Migration
  def change
    tutorial = Tutorial.find(4)
    tutorial.destroy
  end
end
