class PolicyService
  def self.fill_life_policies(policies, life_and_disability)
    policies.values.each do |policy|
      next unless (LifeAndDisabilityPolicy::policy_types.include? policy[:policy_type])
      if policy[:id].present?
        life_and_disability.policy.update(policy[:id], policy)
      else
        life_and_disability.policy << LifeAndDisabilityPolicy.new(policy)
      end
    end
  end
  
  def self.update_contacts(insurance_card, policy_params)
    insurance_card.policy.each_with_index do |policy, index|
      key = policy_params.keys[index]
      return if key.nil?
      
      if policy_params[key].present?
        AccountPolicyOwnerService.fill_life_primary_contact(policy_params[key]["primary_beneficiary_ids"], policy)
        AccountPolicyOwnerService.fill_life_secondary_contact(policy_params[key]["secondary_beneficiary_ids"], policy)
        update_policy_holder(policy_params[key]["policy_holder_id"], policy)
      end
    end
  end
  
  def self.fill_health_policies(policies, health)
    policies.values.each do |policy|
      next unless (HealthPolicy::policy_types.include? policy[:policy_type])
      if policy[:id].present?
        health.policy.update(policy[:id], policy)
      else
        health.policy << HealthPolicy.new(policy)
      end
    end
  end
  
  def self.update_properties(insurance_card, policy_params)
    insurance_card.policy.each_with_index do |policy, index|
      key = policy_params.keys[index]
      
      policy_params[key] && update_policy_holder(policy_params[key]["policy_holder_id"], policy)
    end
  end
  
  def self.update_insured_members(insurance_card, policy_params)
    insurance_card.policy.each_with_index do |policy, index|
      key = policy_params.keys[index]
      policy_params[key]["insured_member_ids"].to_a.select(&:present?).each do |contact_id|
        HealthPoliciesInsuredMember.create(health_policy_id: policy.id, insured_member_id: contact_id)
      end

      policy_params[key] && update_policy_holder(policy_params[key]["policy_holder_id"], policy)
    end
  end
  
  def self.fill_property_and_casualty_policies(policies, property_and_casualty)
    policies.values.each do |policy|
      next unless (PropertyAndCasualtyPolicy::policy_types.include? policy[:policy_type])
      if policy[:id].present?
        property_and_casualty.policy.update(policy[:id], policy)
      else
        property_and_casualty.policy << PropertyAndCasualtyPolicy.new(policy)
      end
    end
  end
  
  def self.update_shares(object_id, share_contact_ids, previous_share_contact_ids, user)
    return if Thread.current[:current_user] != user
    Vendor.find(object_id).shares.clear
    share_contact_ids.each do |x|
      Vendor.find(object_id).shares << Share.create(contact_id: x, user_id: user.id)
    end
    return if previous_share_contact_ids.nil?
    ShareInheritanceService.update_document_shares(user, share_contact_ids, previous_share_contact_ids,
                                                   Rails.application.config.x.InsuranceCategory, nil, nil, object_id)
  end
  
  private
  
  def self.update_policy_holder(policy_holder_id, policy)
    if policy_holder_id.present?
      AccountPolicyOwnerService.fill_account_policy_owner(policy_holder_id, policy)
    end
  end
end
