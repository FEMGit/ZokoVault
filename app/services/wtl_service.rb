class WtlService
  def self.get_wills_details(wills)
    wills.collect{|will| [will.executor.id, will.primary_beneficiary_ids,
      will.secondary_beneficiary_ids, will.agent_ids, will.shares.map{|share| share.contact_id}]}
  end
  
  def self.get_trusts_details(trusts)
    trusts.collect{|trust| [trust.agent_ids, trust.trustee_ids, trust.successor_trustee_ids, trust.shares.map{|share| share.contact_id} ]}
  end
  
  def self.get_powers_of_attorney_details(attorneys)
    attorneys.collect{|attorney| [attorney.agent_ids, attorney.shares.map{|share| share.contact_id} ]}
  end
end