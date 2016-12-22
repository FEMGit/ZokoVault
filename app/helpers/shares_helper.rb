module SharesHelper
  def get_shares_contact_uniq(collection)
    collection.map { |item| item.shares.map(&:contact) }.flatten.uniq
  end
end
