class FinancialInformationService
  def self.fill_accounts(accounts, provider, current_user_id)
    accounts.values.each do |account|
      next unless (FinancialAccountInformation::account_types.include? account[:account_type])
      if account[:id].present?
        provider.accounts.update(account[:id], account)
      else
        provider.accounts << FinancialAccountInformation.new(account.merge(:user_id => current_user_id))
      end
    end
  end
  
  def self.fill_alternatives(alternatives, provider, current_user_id)
    alternatives.values.each do |alternative|
      if alternative[:id].present?
        provider.alternatives.update(alternative[:id], alternative)
      else
        provider.alternatives << FinancialAlternative.new(alternative.merge(:user_id => current_user_id))
      end
    end
  end
  
  def self.update_property_owners(property, property_params)
    property.property_owners.clear
    property_params["property_owner_ids"].each do |contact_id|
      FinancialAccountOwner.create(contact_id: contact_id, contactable_id: property.id, contactable_type: property.class)
    end
  end
  
  def self.update_account_owners(provider, account_params)
    provider.accounts.each_with_index do |account, index|
      key = account_params.keys[index]
      account.account_owners.clear
      account_params[key]["account_owner_ids"].to_a.select(&:present?).each do |contact_id|
        FinancialAccountOwner.create(contact_id: contact_id, contactable_id: account.id, contactable_type: account.class)
      end
    end
  end
  
  def self.update_shares(financial_provider, share_with_contact_ids, previous_share_contact_ids, user, financial_subcategory = nil)
    return if share_with_contact_ids.nil? || (Thread.current[:current_user] != user)
    financial_subcategory.shares.clear if financial_subcategory.present?
    financial_provider.shares.clear
    share_with_contact_ids.each do |share_with_contact_id|
      financial_provider.shares << Share.create(contact_id: share_with_contact_id, user_id: user.id)
    end
    return if previous_share_contact_ids.nil?
    ShareInheritanceService.update_document_shares(user, share_with_contact_ids, previous_share_contact_ids,
                                                   Rails.application.config.x.FinancialInformationCategory, nil, financial_provider.id)
  end
end
