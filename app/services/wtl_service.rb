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
    share_contact_ids.uniq.each do |x|
      model.find(object_id).shares << Share.create(contact_id: x, user_id: user_id)
    end
  end
  
  def self.update_document_shares(resource_owner, share_with_ids, previous_shared_with_ids, model, document_group_for_model)
    current_category = Category.fetch(Rails.application.config.x.WtlCategory.downcase)
    share_contact_ids_to_delete = previous_shared_with_ids - share_with_ids
    document_ids_to_update = Document.for_user(resource_owner).where(category: current_category.name, group: document_group_for_model).map(&:id)
    Share.where(user_id: resource_owner.id, shareable_type: 'Document',
                contact_id: share_contact_ids_to_delete, shareable_id: document_ids_to_update).delete_all
  end
end
