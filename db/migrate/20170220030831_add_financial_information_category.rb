class AddFinancialInformationCategory < ActiveRecord::Migration
  def change
    ["Financial Information"].each do |name|
      if Category.find_by(name: name).nil?
        Category.create! name: name, description: name
      end
    end
  end
end
