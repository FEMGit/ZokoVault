class AddInsuranceBrokerTutorial < ActiveRecord::Migration
  def change
    insurance_broker_name = 'Add Insurance Broker'
    if Tutorial.find_by(name: insurance_broker_name).blank?
      Tutorial.create(name: insurance_broker_name, number_of_pages: 1)
    end
  end
end
