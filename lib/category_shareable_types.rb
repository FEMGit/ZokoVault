module CategoryShareableTypes
  SHAREABLE_TYPE = {
    Rails.application.config.x.WillsPoaCategory => ["Will", "PowerOfAttorneyContact"],
    Rails.application.config.x.TrustsEntitiesCategory => ["Trust", "Entity"],
    Rails.application.config.x.InsuranceCategory => ["Vendor"], 
    Rails.application.config.x.TaxCategory => ["Tax"],
    Rails.application.config.x.FinalWishesCategory => ["FinalWish"],
    Rails.application.config.x.FinancialInformationCategory => ["FinancialProvider"] }
end
