class AddFinancialInformationTutorialSubtutorials < ActiveRecord::Migration
  def change
    unless column_exists? :tutorials, :description
      add_column :tutorials, :description, :string
    end
    financial_information_tutorial = 
      Tutorial.create!(name: 'Financial Information', number_of_pages: 1, description: 'I have financial information.')
    
    [ { name: 'I have a financial advisor.', short_name: 'financial-advisor', tutorial_id: financial_information_tutorial.id, number_of_pages: 2 },
      { name: 'I have a checking account.', short_name: 'bank-accounts', tutorial_id: financial_information_tutorial.id, number_of_pages: 1 },
      { name: 'I have investments.', short_name: 'investments', tutorial_id: financial_information_tutorial.id, number_of_pages: 1 },
      { name: 'I have mortgage.', short_name: 'mortgage', tutorial_id: financial_information_tutorial.id, number_of_pages: 1 },
      { name: 'I have valuable property.', short_name: 'valuable-property', tutorial_id: financial_information_tutorial.id, number_of_pages: 1 },
      { name: 'I have credit cards.', short_name: 'credit-cards', tutorial_id: financial_information_tutorial.id, number_of_pages: 1 },
      { name: 'I have jewelry.', short_name: 'jewelry', tutorial_id: financial_information_tutorial.id, number_of_pages: 1 },
      { name: 'I have alternative investments.', short_name: 'alternative-investments', tutorial_id: financial_information_tutorial.id, number_of_pages: 1 },
      { name: 'I own a business.', short_name: 'financial-business', tutorial_id: financial_information_tutorial.id, number_of_pages: 1 } ].each do |subtutorial|
        Subtutorial.create!(name: subtutorial[:name], short_name: subtutorial[:short_name], tutorial_id: subtutorial[:tutorial_id], number_of_pages: subtutorial[:number_of_pages])
      end
  end
end
