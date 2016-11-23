class TaxesService
  def self.fill_taxes(taxes, tax_year_info, current_user_id)
    taxes.values.each do |tax|
      if tax[:id].present?
        tax_year_info.taxes.update(tax[:id], tax)
      else
        tax_year_info.taxes << Tax.new(tax.merge(:user_id => current_user_id))
      end
    end
  end
  
  def self.tax_by_year(year, user)
    TaxYearInfo.for_user(user).where(:year => year).first
  end
end
