class CorporateAdminService
  def self.clean_categories(corporate_admin)
    return unless corporate_admin.present? && corporate_admin.corporate_admin
    CorporateAdminCategory.where(user_id: corporate_admin.try(:id)).destroy_all
  end
  
  def self.add_category_share_for_corporate_employee(corporate_employee_contact:, corporate_admin:, user:)
    return nil unless corporate_employee_contact.present?
    corporate_admin.corporate_categories.each do |category|
      next if Share.find_by(contact_id: corporate_employee_contact.id, shareable: category, user_id: user.id).present?
      user.shares.create(contact_id: corporate_employee_contact.id, shareable: category)
    end
  end
  
  def self.add_category_share_for_corporate_admin(corporate_admin:, corporate_admin_contact:, user:)
    corporate_admin.corporate_categories.each do |category|
      next if Share.find_by(contact_id: corporate_admin_contact.id, shareable: category, user_id: user.id).present?
      user.shares.create(contact_id: corporate_admin_contact.id, shareable: category)
    end
  end
  
  def self.add_categories(corporate_admin, category_names, corporate_admin_state = false)
    return unless corporate_admin.present? && corporate_admin_state && category_names.present?
    categories = Category.select { |c| category_names.keys.include? c.name }
    categories.each do |category|
      CorporateAdminCategory.create(user: corporate_admin, category: category)
    end
  end
end
