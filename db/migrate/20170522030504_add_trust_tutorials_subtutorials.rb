class AddTrustTutorialsSubtutorials < ActiveRecord::Migration
  def change
    unless column_exists? :subtutorials, :number_of_pages
      add_column :subtutorials, :number_of_pages, :integer, :default => 1
      Subtutorial.reset_column_information
    end
    
    unless column_exists? :subtutorials, :short_name
      add_column :subtutorials, :short_name, :string
      Subtutorial.reset_column_information
    end
    
    trust_tutorial_id = Tutorial.find_by(name: 'Trust').try(:id)
    [ { name: 'I have a trust.', short_name: 'my-trust', number_of_pages: 1 },
      { name: 'I have a family entity.', short_name: 'family-entity', number_of_pages: 1 },
      { name: 'I have a trust or entity attorney.', short_name: 'trust-entity-attorney', number_of_pages: 2 } ].each do |subtutorial|
       Subtutorial.create!(name: subtutorial[:name], tutorial_id: trust_tutorial_id, short_name: subtutorial[:short_name],
                           number_of_pages: subtutorial[:number_of_pages])
     end
  end
end
