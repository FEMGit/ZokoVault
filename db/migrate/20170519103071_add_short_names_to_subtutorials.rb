class AddShortNamesToSubtutorials < ActiveRecord::Migration
  def change
    unless column_exists? :subtutorials, :short_name
      add_column :subtutorials, :short_name, :string
    end
    
    Subtutorial.find_by(:name => 'I have Life or Disability Insurance.').update(:short_name => 'life-disability')
    Subtutorial.find_by(:name => 'I have Property Insurance.').update(:short_name => 'property-casualty')
    Subtutorial.find_by(:name => 'I have Health Insurance.').update(:short_name => 'health')
    Subtutorial.find_by(:name => 'I have an Insurance Broker.').update(:short_name => 'insurance-broker')
  end
end
