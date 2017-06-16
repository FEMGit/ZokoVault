class CleanTutorialSelections < ActiveRecord::Migration
  def change
    TutorialSelection.destroy_all
  end
end
