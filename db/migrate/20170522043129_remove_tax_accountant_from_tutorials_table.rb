class RemoveTaxAccountantFromTutorialsTable < ActiveRecord::Migration
  def change
    Tutorial.where(name: 'Add Tax Accountant').destroy_all
  end
end
