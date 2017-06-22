class UpdateNumberOfPagesFamilyTutorials < ActiveRecord::Migration
  def change
    Tutorial.find_by(name: 'My Family').update(number_of_pages: 3)
  end
end
