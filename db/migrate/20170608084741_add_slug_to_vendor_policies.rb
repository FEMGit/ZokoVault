class AddSlugToVendorPolicies < ActiveRecord::Migration
  def change
    unless column_exists? :life_and_disability_policies, :slug
      add_column :life_and_disability_policies, :slug, :string, :unique => true
      LifeAndDisabilityPolicy.reset_column_information
    end
    
    unless column_exists? :health_policies, :slug
      add_column :health_policies, :slug, :string, :unique => true
      HealthPolicy.reset_column_information
    end
    
    unless column_exists? :property_and_casualty_policies, :slug
      add_column :property_and_casualty_policies, :slug, :string, :unique => true
      PropertyAndCasualty.reset_column_information
    end
  end
end
