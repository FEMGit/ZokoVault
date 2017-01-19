class AddFinancialInformationToCategories < ActiveRecord::Migration
  def change
    Category.create! name: 'Financial Information', description: 'Financial Information'
  end
end
