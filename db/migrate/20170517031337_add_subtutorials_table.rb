class AddSubtutorialsTable < ActiveRecord::Migration
  def change
    create_table :subtutorials do |t|
      t.string :name
      t.references :tutorial, index: true, foreign_key: true

      t.timestamps null: false
    end

    # Add Insurance Subtutorials
    insurance_tutotial_id = Tutorial.find_by(name: 'Insurance').id
    ['I have Life or Disability Insurance',
     'I have Property Insurance',
     'I have Health Insurance'].each do |subtutorial|
      Subtutorial.create(name: subtutorial, tutorial_id: insurance_tutotial_id)
    end
  end
end
