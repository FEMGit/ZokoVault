class AddSlugToFinancialProvider < ActiveRecord::Migration
  def change
    unless column_exists? :documents, :slug
      add_column :documents, :slug, :string, :unique => true
      Document.reset_column_information
    end
  end
end
