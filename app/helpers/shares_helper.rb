module SharesHelper
  def get_shares_contact_uniq(collection)
    collection.map { |item| item.shares.map(&:contact) }.flatten.uniq
  end
  
  def exit_shares_path
    return rooth_path if @shared_user.blank?
    if current_user.corporate_manager?
      corporate_accounts_path
    else
      shares_path
    end
  end
end
