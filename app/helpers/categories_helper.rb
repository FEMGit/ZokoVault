module CategoriesHelper
  def wills_poa_empty?(user = current_user)
    return false unless user.present?
    category_name = Category.fetch(Rails.application.config.x.WillsPoaCategory.downcase).name
    Will.for_user(user).blank? && PowerOfAttorney.for_user(user).blank? &&
      PowerOfAttorneyContact.for_user(user).blank? &&
      Document.for_user(user).where(category: category_name).blank? &&
      Contact.for_user(user).where(relationship: 'Attorney', contact_type: 'Advisor').blank?
  end

  def trusts_entities_empty?(user = current_user)
    return false unless user.present?
    category_name = Category.fetch(Rails.application.config.x.TrustsEntitiesCategory.downcase).name
    Trust.for_user(user).blank? && Entity.for_user(user).blank? &&
      Document.for_user(user).where(category: category_name).blank? &&
      Contact.for_user(user).where(relationship: 'Attorney', contact_type: 'Advisor').blank?
  end

  def insurance_empty?(user = current_user)
    return false unless user.present?
    category_name = Category.fetch(Rails.application.config.x.InsuranceCategory.downcase).name
    Vendor.for_user(user).blank? &&
      Document.for_user(user).where(category: category_name).blank? &&
      Contact.for_user(user).where(relationship: 'Insurance Agent / Broker', contact_type: 'Advisor').blank?
  end

  def financial_information_empty?(user = current_user)
    return false unless user.present?
    category_name = Category.fetch(Rails.application.config.x.FinancialInformationCategory.downcase).name
    FinancialAccountInformation.for_user(user).blank? &&
      FinancialInvestment.for_user(user).blank? &&
      FinancialAlternative.for_user(user).blank? &&
      FinancialProperty.for_user(user).blank? &&
      FinancialProvider.for_user(user).blank? &&
      Document.for_user(user).where(category: category_name).blank? &&
      Contact.for_user(user).where(relationship: 'Financial Advisor / Broker', contact_type: 'Advisor').blank?
  end

  def taxes_empty?(user = current_user)
    return false unless user.present?
    category_name = Category.fetch(Rails.application.config.x.TaxCategory.downcase).name
    Tax.for_user(user).blank? &&
      Document.for_user(user).where(category: category_name).blank? &&
      Contact.for_user(user).where(relationship: 'Accountant', contact_type: 'Advisor').blank?
  end
  
  def final_wishes_empty?(user = current_user)
    return false unless user.present?
    category_name = Category.fetch(Rails.application.config.x.FinalWishesCategory.downcase).name
    FinalWish.for_user(user).blank? &&
      Document.for_user(user).where(category: category_name).blank?
  end
  
  def online_accounts_empty?(user = current_user)
    return false unless user.present?
    category_name = Category.fetch(Rails.application.config.x.FinalWishesCategory.downcase).name
    OnlineAccount.for_user(user).blank?
  end
  
  def vault_inheritance_empty?(user = current_user)
    return false unless user.present? && user.user_profile.present?
    user.full_primary_shared_with.blank?
  end
  
  def vault_co_owner_empty?(user = current_user)
    return false unless user.present? && user.user_profile.present?
    user.primary_shared_with.blank?
  end
end
