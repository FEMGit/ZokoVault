class AddPositionToTutorials < ActiveRecord::Migration
  def change
    unless column_exists? :tutorials, :position
      add_column :tutorials, :position, :integer
      Tutorial.reset_column_information
    end
  
    ['Add Primary Contact', 'Wills', 'Insurance',
     'Taxes', 'Trust', 'Financial Information', 'Vehicle',
     'Home'].each_with_index do |tut_name, index|
       Tutorial.find_by(name: tut_name).update(position: index)
     end
  end
end
