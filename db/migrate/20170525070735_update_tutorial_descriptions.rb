class UpdateTutorialDescriptions < ActiveRecord::Migration
  def change
    Tutorial.find_by(name: 'Wills').update(description: 'I have a will.')
    Tutorial.find_by(name: 'Insurance').update(description: 'I have insurance.')
    Tutorial.find_by(name: 'Home').update(description: 'I have a home.')
    Tutorial.find_by(name: 'Add Primary Contact').update(description: 'I have a family.')
    Tutorial.find_by(name: 'Vehicle').update(description: 'I own a vehicle.')
    Tutorial.find_by(name: 'Trust').update(description: 'I have a trust.')
  end
end
