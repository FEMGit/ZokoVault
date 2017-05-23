class MoveLifePolicyHolders < ActiveRecord::Migration
  def change
    account_policy_owners = AccountPolicyOwner.select { |a| a.contactable_type == 'LifeAndDisabilityPolicy' && a.contact_id.present? }
    LifeAndDisabilityPolicy.select(&:policy_holder_id).each do |life|
      if account_policy_owners.select { |a| a.contactable_id == life.id }.blank?
        AccountPolicyOwner.create(contact_id: life.policy_holder_id, contactable_id: life.id, contactable_type: 'LifeAndDisabilityPolicy')
      end
    end
  end
end
