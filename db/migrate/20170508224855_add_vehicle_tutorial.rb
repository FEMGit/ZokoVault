class AddVehicleTutorial < ActiveRecord::Migration
  def change
    Tutorial.create(name: 'Vehicle', number_of_pages: 1)
  end
end
