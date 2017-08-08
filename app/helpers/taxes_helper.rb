module TaxesHelper
  def link_to_details(year)
    tax_year = @taxes.detect { |tax| tax.year == year }
    return unless tax_year
    return tax_path(tax_year) unless @shared_user
    tax_shared_view_path(@shared_user, tax_year.id)
  end

  def link_to_add_details(year)
    tax_year = @taxes.detect { |tax| tax.year == year }
    if tax_year && tax_year.taxes.any?
      return tax_path(tax_year) unless @shared_user
      tax_shared_view_path(@shared_user, tax_year.id)
    else
      return new_tax_path(:year => year) unless @shared_user
      new_tax_shared_view_path(@shared_user, year)
    end
  end
  
  def tax_by_year(year)
    tax_year = @taxes.where(:year => year).first
    tax_year.taxes.first
  end

  def year_exist?(taxes, year)
    tax_year_info = taxes.detect { |x| x.year == year }
    tax_year_info && tax_year_info.taxes.any?
  end
  
  def tax_year_info(year)
    @taxes.where(:year => year).first
  end
  
  def tax_present?(tax)
    tax.tax_preparer.present? || tax.notes.present? || category_subcategory_shares(tax, tax.user).present?
  end
  
  def tax_accountant_years(tax_accountant)
    tax_year_info_ids = Tax.for_user(resource_owner).where(tax_preparer: tax_accountant).map(&:tax_year_id)
    TaxYearInfo.for_user(resource_owner).where(id: tax_year_info_ids).map(&:year)
  end
end
