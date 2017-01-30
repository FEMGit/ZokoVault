class PolicyService
  def self.fill_life_policies(policies, life_and_disability)
    policies.values.each do |policy|
      if policy[:id].present?
        life_and_disability.policy.update(policy[:id], policy)
      else
        life_and_disability.policy << LifeAndDisabilityPolicy.new(policy)
      end
    end
  end
  
  def self.fill_health_policies(policies, health)
    policies.values.each do |policy|
      if policy[:id].present?
        health.policy.update(policy[:id], policy)
      else
        health.policy << HealthPolicy.new(policy)
      end
    end
  end
  
  def self.fill_property_and_casualty_policies(policies, property_and_casualty)
    policies.values.each do |policy|
      if policy[:id].present?
        property_and_casualty.policy.update(policy[:id], policy)
      else
        property_and_casualty.policy << PropertyAndCasualtyPolicy.new(policy)
      end
    end
  end
  
  def self.update_shares(object_id, share_contact_ids, previous_share_contact_ids, user)
    Vendor.find(object_id).shares.clear
    share_contact_ids.each do |x|
      Vendor.find(object_id).shares << Share.create(contact_id: x, user_id: user.id)
    end
    return if previous_share_contact_ids.nil?
    ShareInheritanceService.update_document_shares(user, share_contact_ids, previous_share_contact_ids,
                                                   Rails.application.config.x.InsuranceCategory, nil, nil, object_id)
  end
end
