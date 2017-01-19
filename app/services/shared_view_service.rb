class SharedViewService
  def self.shared_categories_full(shares)
    @shared_category_names_full = shares.map(&:shareable).select { |s| s.is_a? Category }.map(&:name)
    shares.map(&:shareable).each do |shareable|
      case shareable
      when Will || Trust || PowerOfAttorney
        @shared_category_names_full |= ['Wills - Trusts - Legal']
      when Health || PropertyAndCasualty || LifeAndDisabilities
        @shared_category_names_full |= ['Insurance']
      when Tax
        @shared_category_names_full |= ['Taxes']
      when FinalWish
        @shared_category_names_full |= ['Final Wishes']
      when FinancialInformation
        @shared_category_names_full |= ['Financial Information']
      end
    end
    @shared_category_names_full
  end
  
  def self.shared_group_names(owner, non_owner, category)
    all_shares = shares(owner, non_owner).map(&:shareable).delete_if { |x| x.is_a? Category}.compact
    groups = []
    all_shares.each do |shareable|
      unless shareable.category == Category.fetch(category.downcase)
        next
      end
      case shareable
      when Will
        groups << 'Will'
      when Trust
        groups << 'Trust'
      when PowerOfAttorney
        groups << 'Legal'
      when Tax
        tax_year = TaxYearInfo.find_by(id: shareable.tax_year_id)
        next unless tax_year.present?
        groups << tax_year.year.to_s
      when FinalWish
        final_wish_info = FinalWishInfo.find_by(id: shareable.final_wish_info_id)
        next unless final_wish_info.present?
        groups << final_wish_info.group
      else
        next
      end
    end
    groups.uniq
  end

  private
  
  def self.shares(owner, non_owner)
    owner.shares.where(contact: Contact.where(emailaddress: non_owner.email))
  end
end