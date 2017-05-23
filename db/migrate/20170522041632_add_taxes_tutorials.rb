class AddTaxesTutorials < ActiveRecord::Migration
  def change
    unless column_exists? :tutorials, :description
      add_column :tutorials, :description, :string
    end
    
    tax_tutorial = Tutorial.create!(name: 'Taxes', description: 'I have tax documents.', number_of_pages: 1)
    
    unless column_exists? :subtutorials, :short_name
      add_column :subtutorials, :short_name, :string
    end
    
    unless column_exists? :subtutorials, :number_of_pages
      add_column :subtutorials, :number_of_pages, :integer
    end
    
    [ { name: 'I want to store my digital tax files.', short_name: 'digital-taxes', number_of_pages: 1},
      { name: 'I have a tax accountant.', short_name: 'tax-accountant', number_of_pages: 2 }].each do |subtutorial|
        Subtutorial.create!(name: subtutorial[:name], short_name: subtutorial[:short_name],
                           number_of_pages: subtutorial[:number_of_pages], tutorial_id: tax_tutorial.id)
      end
  end
end
