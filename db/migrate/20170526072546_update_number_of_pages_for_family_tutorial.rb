class UpdateNumberOfPagesForFamilyTutorial < ActiveRecord::Migration
  def change
    tutorial = Tutorial.where('name ILIKE? ', 'I have a family.').try(:first)
    if tutorial.present?
      tutorial.update(number_of_pages: 3)
    end
  end
end
