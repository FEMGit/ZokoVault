class FixNumberOfTutorialPagesForWills < ActiveRecord::Migration
  def change
    Subtutorial.find_by(name: "My estate planning attorney.").update(:number_of_pages => 2)
  end
end
