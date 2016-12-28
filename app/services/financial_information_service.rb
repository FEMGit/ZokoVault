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
end
