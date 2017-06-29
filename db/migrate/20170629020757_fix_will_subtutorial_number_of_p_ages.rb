class FixWillSubtutorialNumberOfPAges < ActiveRecord::Migration
  def change
    Subtutorial.find_by(name: 'My estate planning attorney.').update(number_of_pages: 1)
  end
end
