class AddCategoryData < ActiveRecord::Migration
  def change
    ["Wills - Trusts - Legal",
     "Insurance",
     "Vault",
     "Taxes",
     "Healthcare Choices",
     "Final Wishes"].each do |name|
       Category.create! name: name, description: name
     end
  end
end
