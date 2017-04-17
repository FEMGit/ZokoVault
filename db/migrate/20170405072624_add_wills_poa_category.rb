class AddWillsPoaCategory < ActiveRecord::Migration
  def change
    ["Wills - POA"].each do |name|
      if Category.find_by(name: name).nil?
        Category.create! name: name, description: name
      end
    end
  end
end
