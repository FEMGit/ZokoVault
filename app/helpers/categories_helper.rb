module CategoriesHelper
  def wills_poa_empty?
    return false unless current_user.present?
    category_name = Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase).name
    Will.for_user(current_user).blank? && PowerOfAttorney.for_user(current_user).blank? &&
      PowerOfAttorneyContact.for_user(current_user).blank? &&
      Document.for_user(current_user).where(category: category_name).blank? &&
      Contact.for_user(current_user).where(relationship: 'Attorney', contact_type: 'Advisor').blank?
  end

  def trusts_entities_empty?
    return false unless current_user.present?
    category_name = Category.fetch(Rails.application.config.x.TrustsEntitiesCategory.downcase).name
    Trust.for_user(current_user).blank? && Entity.for_user(current_user).blank? &&
      Document.for_user(current_user).where(category: category_name).blank? &&
      Contact.for_user(current_user).where(relationship: 'Attorney', contact_type: 'Advisor').blank?
  end

  def insurance_empty?
    return false unless current_user.present?
    category_name = Category.fetch(Rails.application.config.x.InsuranceCategory.downcase).name
    Vendor.for_user(current_user).blank? &&
      Document.for_user(current_user).where(category: category_name).blank? &&
      Contact.for_user(current_user).where(relationship: 'Insurance Agent / Broker', contact_type: 'Advisor').blank?
  end
end
