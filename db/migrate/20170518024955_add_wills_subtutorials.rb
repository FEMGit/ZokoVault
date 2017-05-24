class AddWillsSubtutorials < ActiveRecord::Migration
  def change
    Tutorial.where(name: 'Add Estate Planning Attorney').destroy_all
    wills_tutorial = Tutorial.create(name: 'Wills', number_of_pages: 1)
    
    ['I have a will.',
     'My spouse has a will.',
     'I have an estate planning attorney.'].each do |subtutorial|
      Subtutorial.create(name: subtutorial, tutorial_id: wills_tutorial.id)
    end
  end
end
