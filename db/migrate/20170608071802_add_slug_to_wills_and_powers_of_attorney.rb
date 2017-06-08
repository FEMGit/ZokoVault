class AddSlugToWillsAndPowersOfAttorney < ActiveRecord::Migration
  def change
    unless column_exists? :wills, :slug
      add_column :wills, :slug, :string, :unique => true
      Will.reset_column_information
    end
    
    unless column_exists? :power_of_attorneys, :slug
      add_column :power_of_attorneys, :slug, :string, :unique => true
      PowerOfAttorney.reset_column_information
    end
    
    unless column_exists? :power_of_attorney_contacts, :slug
      add_column :power_of_attorney_contacts, :slug, :string, :unique => true
      PowerOfAttorneyContact.reset_column_information
    end
  end
end
