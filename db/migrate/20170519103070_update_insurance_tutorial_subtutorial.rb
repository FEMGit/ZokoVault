class UpdateInsuranceTutorialSubtutorial < ActiveRecord::Migration
  def change
    insurance_tutorial = Tutorial.find_by(name: 'Insurance')
    insurance_tutorial.update!(:number_of_pages => 1)
    Tutorial.where(name: 'Add Insurance Broker').destroy_all
    Subtutorial.create!(name: 'I have an Insurance Broker.', tutorial_id: insurance_tutorial.id)
  end
end
