class AddSlugToTrustAndEntities < ActiveRecord::Migration
  def change
    unless column_exists? :trusts, :slug
      add_column :trusts, :slug, :string, :unique => true
      Trust.reset_column_information
    end
    
    unless column_exists? :entities, :slug
      add_column :entities, :slug, :string, :unique => true
      Entity.reset_column_information
    end
  end
end
