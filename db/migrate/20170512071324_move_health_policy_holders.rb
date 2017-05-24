class MoveHealthPolicyHolders < ActiveRecord::Migration
  def change
    account_policy_owners = AccountPolicyOwner.select { |a| a.contactable_type == 'HealthPolicy' && a.contact_id.present? }
    HealthPolicy.select(&:policy_holder_id).each do |health|
      if account_policy_owners.select { |a| a.contactable_id == health.id }.blank?
        AccountPolicyOwner.create(contact_id: health.policy_holder_id, contactable_id: health.id, contactable_type: 'HealthPolicy')
      end
    end
  end
end
