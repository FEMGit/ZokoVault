class FinancialInformationService
  def self.fill_accounts(accounts, provider, current_user_id)
    accounts.values.each do |account|
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
  
  def self.update_shares(financial_provider, share_with_contact_ids, previous_share_contact_ids, user)
    return if share_with_contact_ids.nil?
    financial_provider.shares.clear
    share_with_contact_ids.each do |share_with_contact_id|
      financial_provider.shares << Share.create(contact_id: share_with_contact_id, user_id: user.id)
    end
    return unless previous_share_contact_ids.present?
    ShareInheritanceService.update_document_shares(FinancialProvider, [financial_provider.id], user.id, previous_share_contact_ids, share_with_contact_ids, nil, financial_provider.id, nil)
  end
end
