module TrustsHelper
  def get_shares_uniq(trusts)
    trusts.map{|trust| trust.shares.map{|share| share.contact}}.flatten.uniq
  end
  
  def get_agents_uniq(trusts)
    trusts.first.agents
  end
end
