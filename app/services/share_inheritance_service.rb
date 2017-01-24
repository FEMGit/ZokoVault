class ShareInheritanceService
  def self.update_document_shares(model, record_ids, user_id, previous_share_contact_ids, share_contact_ids,
                                  group = nil, financial_information_id = nil, vendor_id = nil)
    records = model.where(user_id: user_id, id: record_ids)
    records.each do |record|
      documents = 
        if financial_information_id.present?
          Document.where(user_id: user_id, financial_information_id: financial_information_id)
        elsif vendor_id.present?
          Document.where(user_id: user_id, vendor_id: vendor_id)
        elsif group.present?
          Document.where(user_id: user_id, group: group, category: record.category.name)
        end
      documents.each do |document|
        share_contact_ids.map(&:to_i).each do |share_contact_id|
          next if document.shares.map(&:contact_id).include? share_contact_id
          document.shares << Share.create(contact_id: share_contact_id, user_id: user_id)
        end
      end
      delete_share_ids(documents, previous_share_contact_ids - share_contact_ids.map(&:to_i))
    end
  end
  
  private
  
  def self.delete_share_ids(documents, share_contact_ids_to_delete)
    return unless share_contact_ids_to_delete.present?
    shares_to_delete = documents.map(&:shares).flatten.select { |sh| share_contact_ids_to_delete.include? sh.contact_id }
    shares_to_delete.each(&:destroy)
  end
end