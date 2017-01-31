module AttorneysHelper
  def get_shares_uniq(power_of_attorneys)
    power_of_attorneys.map{|power_of_attorney| power_of_attorney.shares.map{|share| share.contact}}.flatten.uniq
  end
  
  def attorney_present?(attorney)
    attorney.agents.present? || attorney.powers.present? || attorney.notes.present? || category_subcategory_shares(attorney, attorney.user).present?
  end
end
