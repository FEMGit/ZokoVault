class DocumentSubcategoryFix < ActiveRecord::Migration
  def change
    Document.where(:category => Rails.application.config.x.InsuranceCategory, :vendor_id => nil).update_all(:group => DocumentService.empty_value)
    Document.where(:category => Rails.application.config.x.FinancialInformationCategory, :financial_information_id => nil).update_all(:group => DocumentService.empty_value)
  end
end
