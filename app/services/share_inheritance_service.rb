class ShareInheritanceService
  def self.contact_ids_to_remove_from_shares(owner, category_id, shareable_category_params)
    previous_share_contact_ids = owner.shares.select(&:shareable_type)
                                             .select { |sh| Object.const_defined?(sh.shareable_type) && (sh.shareable.is_a? Category) && (sh.shareable_id == category_id) }.map(&:contact_id)
    current_share_contact_ids = Contact.find(shareable_category_params[:share_with_contact_ids].reject(&:blank?)).map(&:id)
    previous_share_contact_ids - current_share_contact_ids
  end
  
  def self.remove_document_shares(owner, category_id, shareable_category_params)
    contact_ids_to_remove = contact_ids_to_remove_from_shares(owner, category_id, shareable_category_params)
    Share.where(user_id: owner.id, shareable_type: 'Document', contact_id: contact_ids_to_remove).delete_all
  end
  
  def self.remove_subcategory_shares(owner, category_id, shareable_category_params)
    contact_ids_to_remove = contact_ids_to_remove_from_shares(owner, category_id, shareable_category_params)
    category = Category.find(category_id)
    if category.name == Rails.application.config.x.WillsPoaCategory
      Share.where(user_id: owner.id, shareable_type: 'Will', contact_id: contact_ids_to_remove).delete_all
      Share.where(user_id: owner.id, shareable_type: 'PowerOfAttorneyContact', contact_id: contact_ids_to_remove).delete_all
    elsif category.name == Rails.application.config.x.WillsPoaCategory
      Share.where(user_id: owner.id, shareable_type: 'Trust', contact_id: contact_ids_to_remove).delete_all
      Share.where(user_id: owner.id, shareable_type: 'Entity', contact_id: contact_ids_to_remove).delete_all
    elsif category.name == Rails.application.config.x.WtlCategory
      Share.where(user_id: owner.id, shareable_type: 'Will', contact_id: contact_ids_to_remove).delete_all
      Share.where(user_id: owner.id, shareable_type: 'Trust', contact_id: contact_ids_to_remove).delete_all
      Share.where(user_id: owner.id, shareable_type: 'PowerOfAttorney', contact_id: contact_ids_to_remove).delete_all
    elsif category.name == Rails.application.config.x.InsuranceCategory
      Share.where(user_id: owner.id, shareable_type: 'Vendor', contact_id: contact_ids_to_remove).delete_all
    elsif category.name == Rails.application.config.x.TaxCategory
      Share.where(user_id: owner.id, shareable_type: 'Tax', contact_id: contact_ids_to_remove).delete_all
    elsif category.name == Rails.application.config.x.FinalWishesCategory
      Share.where(user_id: owner.id, shareable_type: 'FinalWish', contact_id: contact_ids_to_remove).delete_all
    elsif category.name == Rails.application.config.x.FinancialInformationCategory
      Share.where(user_id: owner.id, shareable_type: 'FinancialProvider', contact_id: contact_ids_to_remove).delete_all
    end
  end
  
    def self.update_document_shares(resource_owner, share_with_ids, previous_shared_with_ids, category_name, document_group_for_model = nil,
                                    financial_information_id = nil, vendor_id = nil, card_document_id = nil)
    share_contact_ids_to_delete = previous_shared_with_ids - share_with_ids
    document_ids_to_update =
      if document_group_for_model.present?
        Document.for_user(resource_owner).where(category: category_name, group: document_group_for_model).map(&:id)
      elsif financial_information_id.present?
        Document.for_user(resource_owner).where(category: category_name, financial_information_id: financial_information_id).map(&:id)
      elsif vendor_id.present?
        Document.for_user(resource_owner).where(category: category_name, vendor_id: vendor_id).map(&:id)
      elsif card_document_id.present?
        Document.for_user(resource_owner).where(category: category_name, card_document_id: card_document_id).map(&:id)
      end
    Share.where(user_id: resource_owner.id, shareable_type: 'Document',
                contact_id: share_contact_ids_to_delete, shareable_id: document_ids_to_update).delete_all
  end
end