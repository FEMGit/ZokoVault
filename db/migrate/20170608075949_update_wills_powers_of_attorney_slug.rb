class UpdateWillsPowersOfAttorneySlug < ActiveRecord::Migration
  def change
    Will.find_each(:batch_size => 1000) do |will|
      next unless will.user
      will.save!
    end
    
    PowerOfAttorney.find_each(:batch_size => 1000) do |poa|
      next unless poa.user
      poa.save!
    end
    
    PowerOfAttorneyContact.find_each(:batch_size => 1000) do |poa_contact|
      next unless poa_contact.user
      poa_contact.save!
    end
  end
end
