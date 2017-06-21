class AddUploadInsurancePolicySubtutorial < ActiveRecord::Migration
  def change
    insurance_tutorial_id = Tutorial.find_by(name: 'My Insurance').try(:id)
    Subtutorial.create(name: 'Upload my policies.', tutorial_id: insurance_tutorial_id, number_of_pages: 1)
  end
end
