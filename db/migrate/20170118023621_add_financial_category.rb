class AddFinancialCategory < ActiveRecord::Migration
  def change
    ["Financial Information"].each do |name|
       Category.create! name: name, description: name
     end
  end
end
