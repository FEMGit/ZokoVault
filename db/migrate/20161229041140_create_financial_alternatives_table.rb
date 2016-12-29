class CreateFinancialAlternativesTable < ActiveRecord::Migration
  def change
    create_table :financial_alternatives do |t|
      t.integer :alternative_type
      t.string :name
      t.integer :owner_id
      t.decimal :commitment
      t.decimal :total_calls
      t.decimal :total_distributions
      t.decimal :current_value
      t.integer :primary_contact_id
      t.string :notes
      t.integer :manager_id
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
