class AddDocumentCategoryToCategories < ActiveRecord::Migration
  def change
    ["Documents"].each do |name|
      if Category.find_by(name: name).blank?
        Category.create! name: name, description: name
      end
    end
  end
end
