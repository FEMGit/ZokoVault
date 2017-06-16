class UpdateWillSubtutorialsNames < ActiveRecord::Migration
  def change
    Subtutorial.find_by(name: 'I have a will.').update(:name => 'My will.')
    Subtutorial.find_by(name: 'My spouse has a will.').update(:name => "My spouse's will.")
    Subtutorial.find_by(name: 'I have an estate planning attorney.').update(:name => "My estate planning attorney.")
  end
end
