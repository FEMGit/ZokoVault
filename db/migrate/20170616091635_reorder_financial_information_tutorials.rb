class ReorderFinancialInformationTutorials < ActiveRecord::Migration
  def change
    Subtutorial.find_by(:name => "My financial advisor.").update(:position => 0)
    Subtutorial.find_by(:name => "My checking account.").update(:name => "My bank accounts.", :position => 1)
    Subtutorial.find_by(:name => "My valuable property.").update(:position => 2)
    Subtutorial.find_by(:name => "My business.").update(:position => 3)
    Subtutorial.find_by(:name => "My alternative investments.").update(:position => 4)
    Subtutorial.find_by(:name => "My investments.").update(:name => "My other investments", :position => 5)
    
    Subtutorial.where(:name => ['My mortgage.', 'My credit cards', 'My jewelry.']).destroy_all
  end
end
