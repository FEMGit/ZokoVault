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
end
