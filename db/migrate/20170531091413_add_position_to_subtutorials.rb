class AddPositionToSubtutorials < ActiveRecord::Migration
  def change
    unless column_exists? :subtutorials, :position
      add_column :subtutorials, :position, :integer, default: 0
      Subtutorial.reset_column_information
    end
    
    Subtutorial.find_by(name: 'I have a tax accountant.').update(:position => 0)
    Subtutorial.find_by(name: 'I want to store my digital tax files.').update(:position => 1)
  end
end
