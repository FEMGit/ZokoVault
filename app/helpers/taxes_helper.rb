module TaxesHelper
<<<<<<< HEAD
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

  def tax_by_year(year)
    tax_year = @taxes.where(:year => year).first
    tax_year.taxes.first
  end

  def year_exist?(taxes, year)
    taxes.any? { |x| x.year == year }
  end
=======
>>>>>>> d74ad9e... Ad-379 - details tax card
end
