module TrustsHelper
  def get_shares_uniq(trusts)
    trusts.map{|trust| trust.shares.map{|share| share.contact}}.flatten.uniq
  end
  
  def get_agents_uniq(trusts)
    trusts.first.agents
  end
  
  def trust_present?(trust)
    trust.trustees.present? || trust.successor_trustees.present? || trust.agents.present? || trust.notes.present? ||
      category_subcategory_shares(trust, trust.user).present?
  end
end
