class AddBalanceSheetTutorial < ActiveRecord::Migration
  def change
    tutorial_count = Tutorial.all.count
    shares_position = Tutorial.find_by(:name => "Shares").position
    Tutorial.create!(:name => "Balance Sheet", :number_of_pages => 1, :checkbox_present => false, position: shares_position)
    Tutorial.find_by(:name => "Shares").update(position: tutorial_count)
  end
end
