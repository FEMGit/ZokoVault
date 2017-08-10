module CategoryDropdownOptions
  CATEGORIES = {
    common_user: [ "Select...",
                  Rails.application.config.x.FinancialInformationCategory,
                  Rails.application.config.x.WillsPoaCategory,
                  Rails.application.config.x.TrustsEntitiesCategory,
                  Rails.application.config.x.InsuranceCategory,
                  Rails.application.config.x.TaxCategory,
                  Rails.application.config.x.FinalWishesCategory,
                  Rails.application.config.x.ContactCategory,
                  Rails.application.config.x.ProfileCategory ],
    corporate_manager: [ Rails.application.config.x.ProfileCategory ]
  }
end
