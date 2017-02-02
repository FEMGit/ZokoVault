module CategoryLinks
  LINKS = [ {name: Rails.application.config.x.InsuranceCategory, path: Rails.application.routes.url_helpers.insurance_path},
            {name: Rails.application.config.x.ContactCategory, path: Rails.application.routes.url_helpers.contacts_path},
            {name: Rails.application.config.x.TaxCategory, path: Rails.application.routes.url_helpers.taxes_path},
            {name: Rails.application.config.x.FinalWishesCategory, path: Rails.application.routes.url_helpers.final_wishes_path},
            {name: Rails.application.config.x.FinancialInformationCategory, path: Rails.application.routes.url_helpers.financial_information_path},
            {name: Rails.application.config.x.ProfileCategory, path: Rails.application.routes.url_helpers.user_profile_path},
            {name: Rails.application.config.x.WtlCategory, path: Rails.application.routes.url_helpers.estate_planning_path}]
end