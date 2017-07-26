module OnlineAccountHelper
  def online_account_shares(account)
    return [] unless (account.user.eql? resource_owner) && account.category.present?
    category_shares = account.user.shares.reject{ |x| x.shareable_type.nil? }.select { |sh| sh.shareable == account.category }
    (account.shares + category_shares).uniq(&:contact_id)
  end
end
