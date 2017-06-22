class UpdateNumberOfPagesForTaxAccountantSubtutorial < ActiveRecord::Migration
  def change
    Subtutorial.find_by(name: 'My tax accountant.').update(number_of_pages: 2)
  end
end
