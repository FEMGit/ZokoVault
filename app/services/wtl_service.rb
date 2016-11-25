class WtlService
  def self.get_wills_details(wills)
    wills.collect{|will| [will.executor.nil? ? "" : will.executor.id, will.primary_beneficiary_ids,
      will.secondary_beneficiary_ids, will.agent_ids, will.shares.map{|share| share.contact_id}, will.id, will.notes]}
  end
  
  def self.get_trusts_details(trusts)
    trusts.collect{|trust| [trust.agent_ids, trust.trustee_ids, trust.successor_trustee_ids, trust.share_with_contact_ids, trust.id, trust.notes]}
  end
  
  def self.get_powers_of_attorney_details(attorneys)
    attorneys.collect{|attorney| [attorney.agent_ids, attorney.shares.map{|share| share.contact_id}, attorney.id, attorney.notes ]}
  end
  
  def self.clear_one_option(options)
    if options.present?
      options.values.select{|x| x.is_a?(Array)}.map{|x| x.delete_if(&:empty?)}
    end
  end
  
  def self.get_new_records(params)
    params.values.select{|x| x["id"] == ""}
  end
  
  def self.get_old_records(params)
    params.values.select{|x| x["id"] != "" && !x["id"].nil?}
  end
end