module FormLimitationsHelper
  def get_max_length(field_type)
    type_limit = FormLimitations::TYPE_LIMITS.detect { |l| l[:type].eql? field_type }
    return default_limit if type_limit.blank?
    type_limit[:limit]
  end
  
  private
  
  def default_limit
    FormLimitations::TYPE_LIMITS.detect { |l| l[:type].eql? :default }[:limit]
  end
end