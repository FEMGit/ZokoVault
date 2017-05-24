class AddNoPageColumnToSubtutorials < ActiveRecord::Migration
  def change
    unless column_exists? :subtutorials, :no_page
      add_column :subtutorials, :no_page, :boolean, default: false
      Subtutorial.reset_column_information
    end
    
    ['my-will', 'spouse-will'].each do |short_name|
      Subtutorial.find_by(short_name: short_name).update(no_page: true)
     end
  end
end
