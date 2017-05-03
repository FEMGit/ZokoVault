class WtlService
  def self.clear_one_option(options)
    return unless options.present?
    options.values.select{|x| x.is_a?(Array)}.map{|x| x.delete_if(&:empty?)}
  end
  
  def self.get_new_records(params)
    params.values.select{ |values| values["id"].blank? }
  end
  
  def self.get_old_records(params)
    params.values.select{ |values| values["id"].present? }
  end
  
  def self.fill_power_of_attorneys(power_of_attorneys, power_of_attorney_contact)
    power_of_attorneys.values.each do |power_of_attorney|
      if power_of_attorney[:id].present?
        power_of_attorney_contact.power_of_attorneys.update(power_of_attorney[:id], power_of_attorney)
      else
        power_of_attorney.except!(:agent_ids)
        power_of_attorney_contact.power_of_attorneys << PowerOfAttorney.create(power_of_attorney.merge(user_id: power_of_attorney_contact.user_id, category: Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase)))
      end
    end
  end
  
  def self.fill_agents(power_of_attorney_contact, power_of_attorney_params)
    power_of_attorney_contact.power_of_attorneys.each_with_index do |attorney, index|
      key = power_of_attorney_params.keys[index]
      Array.wrap(power_of_attorney_params[key]["agent_ids"]).select(&:present?).each do |contact_id|
        VaultEntryContact.create(type: VaultEntryContact.types[:power_of_attorney], contact_id: contact_id, contactable_id: attorney.id, contactable_type: 'PowerOfAttorney')
      end
    end
  end
  
  def self.update_shares(object_id, share_contact_ids, user_id, model)
    return unless share_contact_ids.present?
    model.find(object_id).shares.clear
    share_contact_ids.uniq.each do |x|
      model.find(object_id).shares << Share.create(contact_id: x, user: User.find_by(id: user_id), shareable_id: object_id)
    end
  end
  
  def self.update_trustees(trust, trustee_ids, successor_trustee_ids, agent_ids)
    trustee_ids.each do |trustee_id|
      VaultEntryContact.create(type: VaultEntryContact.types[:trustee], active: true, contact_id: trustee_id, contactable_id: trust.id,
                               contactable_type: "Trust")
    end
    
    successor_trustee_ids.each do |trustee_id|
      VaultEntryContact.create(type: VaultEntryContact.types[:successor_trustee], active: true, contact_id: trustee_id, contactable_id: trust.id,
                               contactable_type: "Trust")
    end
    
    Array.wrap(agent_ids).each do |agent_id|
      VaultEntryContact.create(type: VaultEntryContact.types[:agent], active: true, contact_id: agent_id, contactable_id: trust.id,
                               contactable_type: "Trust")
    end
  end
  
  def self.update_beneficiaries(will, primary_beneficiary_ids, secondary_beneficiary_ids, agent_ids)
    primary_beneficiary_ids.each do |primary_id|
      VaultEntryBeneficiary.create(will_id: will.id, contact_id: primary_id, active: true, type: :primary)
    end
    
    secondary_beneficiary_ids.each do |secondary_id|
      VaultEntryBeneficiary.create(will_id: will.id, contact_id: secondary_id, active: true, type: :secondary)
    end
    
    Array.wrap(agent_ids).each do |agent_id|
      VaultEntryContact.create(type: VaultEntryContact.types[:agent], active: true, contact_id: agent_id, contactable_id: will.id,
                               contactable_type: "Will")
    end
  end
  
  def self.update_entity(entity, agent_ids, partner_ids)
    entity.agents.clear
    agent_ids.to_a.each do |agent_id|
      VaultEntryContact.create(type: VaultEntryContact.types[:agent], active: true, contact_id: agent_id, contactable_id: entity.id,
                               contactable_type: "Entity")
    end
    
    entity.partners.clear
    partner_ids.to_a.each do |partner_id|
      AccountPolicyOwnerService.fill_account_policy_owner(partner_id, entity)
    end
  end
end
