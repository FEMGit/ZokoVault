module TaxesHelper
  
  def link_to_details(year)
    tax_year = @taxes.where(:year => year).first
    if tax_year
      "#{taxes_path}/#{tax_year.id}"
    else
      ""
    end
  end
  
  def link_to_add_details(year)
    tax_year = @taxes.where(:year => year).first
    if tax_year
      "#{taxes_path}/#{tax_year.id}/edit"
    else
      new_tax_path(:year => year)
    end
  end
  
  private
  
  def year_exist?(taxes, year)
    taxes.any? { |x| x.year == year }
  end
end
