class RemoveOwnerIdColumnFromFinancialInformations < ActiveRecord::Migration
  def change
    account_owners = FinancialAccountInformation.all.flatten.select { |x| x.owner_id.present? }.collect { |x| [id: x.id, owner_id: x.owner_id] }.flatten
    alternative_owners = FinancialAlternative.all.flatten.select { |x| x.owner_id.present? }.collect { |x| [id: x.id, owner_id: x.owner_id] }.flatten
    property_owners = FinancialProperty.all.flatten.select { |x| x.owner_id.present? }.collect { |x| [id: x.id, owner_id: x.owner_id] }.flatten
    investment_owners = FinancialInvestment.all.flatten.select { |x| x.owner_id.present? }.collect { |x| [id: x.id, owner_id: x.owner_id] }.flatten
    
    account_owners.each do |account|
      next unless Contact.exists?(account[:owner_id])
      FinancialAccountOwner.create(contact_id: account[:owner_id], contactable_id: account[:id], contactable_type: 'FinancialAccountInformation')
    end
    alternative_owners.each do |alternative|
      next unless Contact.exists?(alternative[:owner_id])
      FinancialAccountOwner.create(contact_id: alternative[:owner_id], contactable_id: alternative[:id], contactable_type: 'FinancialAlternative')
    end
    property_owners.each do |property|
      next unless Contact.exists?(property[:owner_id])
      FinancialAccountOwner.create(contact_id: property[:owner_id], contactable_id: property[:id], contactable_type: 'FinancialProperty')
    end
    investment_owners.each do |investment|
      next unless Contact.exists?(investment[:owner_id])
      FinancialAccountOwner.create(contact_id: investment[:owner_id], contactable_id: investment[:id], contactable_type: 'FinancialInvestment')
    end
  end
end
