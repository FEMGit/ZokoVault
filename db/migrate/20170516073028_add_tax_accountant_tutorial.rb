class AddTaxAccountantTutorial < ActiveRecord::Migration
  def change
    tutorial_name = 'Add Tax Accountant'
    if Tutorial.find_by(name: tutorial_name).blank?
      Tutorial.create(name: tutorial_name, number_of_pages: 1)
    end
  end
end
