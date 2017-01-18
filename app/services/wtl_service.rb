class WtlService
  def self.clear_one_option(options)
    return unless options.present?
    options.values.select{|x| x.is_a?(Array)}.map{|x| x.delete_if(&:empty?)}
  end
  
  def self.get_new_records(params)
    params.values.select{ |values| values["id"].blank? }
  end
  
  def self.get_old_records(params)
    params.values.select{ |values| values["id"].present? }
  end
  
  def self.update_shares(object_id, share_contact_ids, user_id, model)
    return unless share_contact_ids.present?
    model.find(object_id).shares.clear
    share_contact_ids.each do |x|
      model.find(object_id).shares << Share.create(contact_id: x, user_id: user_id)
    end
  end
end
