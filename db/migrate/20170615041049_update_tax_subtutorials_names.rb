class UpdateTaxSubtutorialsNames < ActiveRecord::Migration
  def change
    Subtutorial.find_by(name: 'I have a tax accountant.').update(:name => 'My tax accountant.', :position => 0)
    Subtutorial.find_by(name: 'I want to store my digital tax files.').update(:name => 'My digital tax files.', :position => 1)
  end
end
