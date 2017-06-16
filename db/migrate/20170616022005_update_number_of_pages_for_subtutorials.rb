class UpdateNumberOfPagesForSubtutorials < ActiveRecord::Migration
  def change
    subtutorial_1 = Subtutorial.find_by(name: 'I have a tax accountant.') || Subtutorial.find_by(name: 'My tax accountant.')
    subtutorial_1.update(:number_of_pages => 1)
    
    subtutorial_2 = Subtutorial.find_by(name: 'I have a trust or entity attorney.') || Subtutorial.find_by(name: 'My attorney.')
    subtutorial_2.update(:number_of_pages => 1)
    
    subtutorial_3 = Subtutorial.find_by(name: 'I have an estate planning attorney.') || Subtutorial.find_by(name: 'My estate planning attorney.')
    subtutorial_3.update(:number_of_pages => 1)
    
    subtutorial_4 = Subtutorial.find_by(name: 'I have a financial advisor.') || Subtutorial.find_by(name: 'My financial advisor.')
    subtutorial_4.update(:number_of_pages => 1)
  end
end
