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
  
  def self.update_shares(tax_year_info, previous_share_with_contact_ids, user)
    tax_year_info.taxes.each do |tax|
      share_with_contact_ids = tax.share_with_contact_ids
      tax.shares.clear
      share_with_contact_ids.each do |contact_id|
        tax.shares << Share.create(contact_id: contact_id, user_id: user.id)
      end
    end

    share_contact_ids = tax_year_info.taxes.map(&:share_with_contact_ids).uniq
    return unless previous_share_with_contact_ids.present?
    ShareInheritanceService.update_document_shares(user, share_contact_ids, previous_share_with_contact_ids,
                                                   Rails.application.config.x.TaxCategory, tax_year_info.year.to_s)
  end
end
