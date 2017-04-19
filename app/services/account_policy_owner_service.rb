class AccountPolicyOwnerService
  def self.fill_account_policy_owner(contact_id, contactable)
    if contact_id.include? '_contact'
      AccountPolicyOwner.create(contact_id: contact_id_filtered(contact_id), contactable_id: contactable.id, contactable_type: contactable.class)
    elsif contact_id.include? '_owner'
      AccountPolicyOwner.create(card_document_id: contact_id_filtered(contact_id), contactable_id: contactable.id, contactable_type: contactable.class)
    end
  end
  
  def self.fill_life_primary_contact(contact_ids, policy)
    LifeAndDisabilityPoliciesPrimaryBeneficiary.where(life_and_disability_policy_id: policy.id).destroy_all
    contact_ids.to_a.select(&:present?).each do |contact_id|
      if contact_id.include? '_contact'
        LifeAndDisabilityPoliciesPrimaryBeneficiary.create(life_and_disability_policy_id: policy.id, contact_id: contact_id)
      elsif contact_id.include? '_owner'
        LifeAndDisabilityPoliciesPrimaryBeneficiary.create(life_and_disability_policy_id: policy.id, card_document_id: contact_id)
      end
    end
  end
  
  def self.fill_life_secondary_contact(contact_ids, policy)
    LifeAndDisabilityPoliciesSecondaryBeneficiary.where(life_and_disability_policy_id: policy.id).destroy_all
    contact_ids.to_a.select(&:present?).each do |contact_id|
      if contact_id.include? '_contact'
        LifeAndDisabilityPoliciesSecondaryBeneficiary.create(life_and_disability_policy_id: policy.id, contact_id: contact_id)
      elsif contact_id.include? '_owner'
        LifeAndDisabilityPoliciesSecondaryBeneficiary.create(life_and_disability_policy_id: policy.id, card_document_id: contact_id)
      end
    end
  end
  
  private
  
  def self.contact_id_filtered(contact_id)
    contact_id.scan(/[0-9]/).join
  end
end