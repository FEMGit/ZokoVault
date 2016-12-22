module WillsHelper
  def get_primary_uniq(wills)
    wills.first.primary_beneficiaries
  end
  
  def get_secondary_uniq(wills)
    wills.first.secondary_beneficiaries
  end
  
  def get_shares_uniq(wills)
    wills.map{|will| will.shares.map{|share| share.contact}}.flatten.uniq
  end
  
  def get_executors_uniq(wills)
    wills.map{|will| will.executor}.flatten.uniq
  end
  
  def get_advisor_uniq(wills)
    wills.first.agents
  end
  
  def will_present?(will)
    will.primary_beneficiaries.present? || will.secondary_beneficiaries.present? || will.executor.present? ||
      will.agents.present? || will.notes.present? || will.shares.present?
  end
end
