module CategoryLinks
  LINKS = [ {name: Rails.application.config.x.InsuranceCategory, path: Rails.application.routes.url_helpers.insurance_path},
            {name: Rails.application.config.x.ContactCategory, path: Rails.application.routes.url_helpers.contacts_path},
            {name: Rails.application.config.x.TaxCategory, path: Rails.application.routes.url_helpers.taxes_path},
            {name: Rails.application.config.x.FinalWishesCategory, path: Rails.application.routes.url_helpers.final_wishes_path},
            {name: Rails.application.config.x.FinancialInformationCategory, path: Rails.application.routes.url_helpers.financial_information_path},
            {name: Rails.application.config.x.ProfileCategory, path: Rails.application.routes.url_helpers.user_profiles_path},
            {name: Rails.application.config.x.WillsPoaCategory, path: Rails.application.routes.url_helpers.wills_powers_of_attorney_path},
            {name: Rails.application.config.x.TrustsEntitiesCategory, path: Rails.application.routes.url_helpers.trusts_entities_path}]
  
  def self.shared_view_category_link(category_name:, shared_user_id:)
    case category_name.downcase
      when Rails.application.config.x.InsuranceCategory.downcase
        Rails.application.routes.url_helpers.shared_view_insurance_path(:shared_user_id => shared_user_id)
      when Rails.application.config.x.ContactCategory.downcase
        Rails.application.routes.url_helpers.shared_view_contacts_path(:shared_user_id => shared_user_id)
      when Rails.application.config.x.TaxCategory.downcase
        Rails.application.routes.url_helpers.shared_view_taxes_path(:shared_user_id => shared_user_id)
      when Rails.application.config.x.FinalWishesCategory.downcase
        Rails.application.routes.url_helpers.shared_view_final_wishes_path(:shared_user_id => shared_user_id)
      when Rails.application.config.x.FinancialInformationCategory.downcase
        Rails.application.routes.url_helpers.shared_view_financial_information_path(:shared_user_id => shared_user_id)
      when Rails.application.config.x.WillsPoaCategory.downcase
        Rails.application.routes.url_helpers.shared_view_wills_powers_of_attorney_path(:shared_user_id => shared_user_id)
      when Rails.application.config.x.TrustsEntitiesCategory.downcase
        Rails.application.routes.url_helpers.shared_view_trusts_entities_path(:shared_user_id => shared_user_id)
    end
  end
end