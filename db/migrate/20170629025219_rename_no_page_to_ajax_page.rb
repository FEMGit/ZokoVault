class RenameNoPageToAjaxPage < ActiveRecord::Migration
  def change
    rename_column :subtutorials, :no_page, :ajax_page
  end
end
