class ShareInheritanceService
  def self.contact_ids_to_remove_from_shares(owner, category_id, shareable_category_params)
    previous_share_contact_ids = owner.shares.select { |sh| (sh.shareable.is_a? Category) && (sh.shareable_id == category_id) }.map(&:contact_id)
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
    if category.name == Rails.application.config.x.WtlCategory
      Share.where(user_id: owner.id, shareable_type: 'Will', contact_id: contact_ids_to_remove).delete_all
      Share.where(user_id: owner.id, shareable_type: 'Trust', contact_id: contact_ids_to_remove).delete_all
      Share.where(user_id: owner.id, shareable_type: 'PowerOfAttorney', contact_id: contact_ids_to_remove).delete_all
    end
  end
end