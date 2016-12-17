class WtlService
  def self.clear_one_option(options)
    return unless options.present?
    options.values.select{|x| x.is_a?(Array)}.map{|x| x.delete_if(&:empty?)}
  end
  
  def self.get_new_records(params)
    params.values.select{|x| x["id"] == ""}
  end
  
  def self.get_old_records(params)
    params.values.select{|x| x["id"] != "" && !x["id"].nil?}
  end
end
