class UpdateSlugForInsurance < ActiveRecord::Migration
  def change
    Vendor.find_each(:batch_size => 1000) do |vendor|
      next unless vendor.user && vendor.valid?
      vendor.save!
    end
    
    LifeAndDisabilityPolicy.find_each(:batch_size => 1000) do |policy|
      policy.save!
    end
    
    HealthPolicy.find_each(:batch_size => 1000) do |policy|
      policy.save!
    end
    
    PropertyAndCasualtyPolicy.find_each(:batch_size => 1000) do |policy|
      policy.save!
    end
  end
end
