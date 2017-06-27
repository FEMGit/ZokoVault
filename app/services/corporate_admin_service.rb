class CorporateAdminService
  def self.clean_categories(corporate_admin)
    return unless corporate_admin.present? && corporate_admin.corporate_admin
    CorporateAdminCategory.where(user_id: corporate_admin.try(:id)).destroy_all
  end
  
  def self.add_categories_to_user(corporate_admin, user)
    return unless corporate_admin.present? && corporate_admin.corporate_admin
    contacts = Contact.for_user(corporate_admin).select { |c| user.email.downcase == c.emailaddress.downcase }.map(&:id)
    corporate_admin.corporate_categories.each do |category|
      share_categories_with_users(corporate_admin, category, contacts)
    end
  end
  
  def self.add_categories(corporate_admin, category_names)
    return unless corporate_admin.present? && corporate_admin.corporate_admin
    if category_names.blank?
      category_ids = Share.for_user(corporate_admin).select { |sh| sh.shareable.is_a? Category }.map(&:shareable_id)
      remove_category_shares(contact_ids(corporate_admin))
      category_ids.each do |category_id|
        clear_shares(corporate_admin, category_id, contact_ids(corporate_admin))
      end
      return
    end
    
    categories = Category.select { |c| category_names.keys.include? c.name }
    remove_category_shares(contact_ids(corporate_admin))
    categories.each do |category|
      share_categories_with_users(corporate_admin, category, contact_ids(corporate_admin))
      CorporateAdminCategory.create(user: corporate_admin, category: category)
    end
  end
  
  private
  
  def self.contact_ids(corporate_admin)
    user_emails = corporate_admin.corporate_users.compact.map(&:email).map(&:downcase)
    contact_ids = Contact.for_user(corporate_admin).select { |c| user_emails.include? c.emailaddress.downcase }.map(&:id)
  end
  
  def self.clear_shares(user, category_id, share_with_contact_ids)
    remove_document_shares(user, category_id, share_with_contact_ids)
    remove_subcategory_shares(user, category_id, share_with_contact_ids)
  end
  
  def self.share_categories_with_users(user, category, share_with_contact_ids)
    clear_shares(user, category.id, share_with_contact_ids)
    share_with_contact_ids.select(&:present?).each do |contact_id|
      user.shares.create(contact_id: contact_id, shareable: category)
    end
  end
  
  def self.remove_category_shares(share_with_contact_ids)
    Share.where(shareable_type: 'Category', contact_id: share_with_contact_ids).destroy_all
  end
    
  def self.remove_document_shares(user, category_id, share_with_contact_ids)
    ShareInheritanceService.remove_document_shares(user, category_id, share_with_contact_params(share_with_contact_ids))
  end
  
  def self.remove_subcategory_shares(user, category_id, share_with_contact_ids)
    ShareInheritanceService.remove_subcategory_shares(user, category_id, share_with_contact_params(share_with_contact_ids))
  end
  
  def self.share_with_contact_params(contact_ids)
    { :share_with_contact_ids => contact_ids }
  end
end
