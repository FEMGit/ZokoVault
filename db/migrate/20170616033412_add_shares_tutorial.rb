class AddSharesTutorial < ActiveRecord::Migration
  def change
    unless column_exists? :tutorials, :checkbox_present
      add_column :tutorials, :checkbox_present, :bool, :default => true
      Tutorial.reset_column_information
    end
      
    Tutorial.create!(:name => 'Shares', :number_of_pages => 1, :position => 8, :checkbox_present => false)
  end
end
