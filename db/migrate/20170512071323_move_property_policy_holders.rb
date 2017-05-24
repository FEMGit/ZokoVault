class MovePropertyPolicyHolders < ActiveRecord::Migration
  def change
    account_policy_owners = AccountPolicyOwner.select { |a| a.contactable_type == 'PropertyAndCasualtyPolicy' && a.contact_id.present? }
    PropertyAndCasualtyPolicy.select(&:policy_holder_id).each do |property|
      if account_policy_owners.select { |a| a.contactable_id == property.id }.blank?
        AccountPolicyOwner.create(contact_id: property.policy_holder_id, contactable_id: property.id, contactable_type: 'PropertyAndCasualtyPolicy')
      end
    end
  end
end
