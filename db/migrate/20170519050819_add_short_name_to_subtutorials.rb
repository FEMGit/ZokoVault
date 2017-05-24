class AddShortNameToSubtutorials < ActiveRecord::Migration
  def change
    unless column_exists? :subtutorials, :short_name
      add_column :subtutorials, :short_name, :string
      Subtutorial.reset_column_information
    end
    
    [ { name: 'I have a will.', short_name: 'my-will' },
     { name: 'My spouse has a will.', short_name: 'spouse-will' },
     { name: 'I have an estate planning attorney.', short_name: 'estate-attorney' }].each do |subtutorial|
      Subtutorial.find_by(name: subtutorial[:name]).update!(short_name: subtutorial[:short_name])
    end
  end
end
