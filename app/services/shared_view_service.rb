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
end