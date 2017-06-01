class MoveSonDaughterToChild < ActiveRecord::Migration
  def change
    Contact.where(:relationship => ['Son', 'Daughter']).update_all(:relationship => 'Child')
  end
end
