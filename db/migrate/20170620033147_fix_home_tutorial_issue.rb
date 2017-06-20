class FixHomeTutorialIssue < ActiveRecord::Migration
  def change
    Tutorial.find_by(:name => 'My Home').update(:number_of_pages => 1)
  end
end
