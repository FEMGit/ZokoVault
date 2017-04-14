class SharedViewService
  def self.shared_categories_full(shares)
    @shared_category_names_full = shares.select(&:shareable_type).select { |sh| Object.const_defined?(sh.shareable_type) && (sh.shareable.is_a? Category) }.map(&:shareable).map(&:name)
    shares.select(&:shareable_type).select { |sh| Object.const_defined?(sh.shareable_type) }.map(&:shareable).each do |shareable|
      case shareable
      when Will, PowerOfAttorneyContact
        @shared_category_names_full |= ['Wills - POA']
      when Will, Trust, PowerOfAttorney
        @shared_category_names_full |= ['Wills - Trusts - Legal']
      when Health, PropertyAndCasualty, LifeAndDisability
        @shared_category_names_full |= ['Insurance']
      when Tax
        @shared_category_names_full |= ['Taxes']
      when FinalWish
        @shared_category_names_full |= ['Final Wishes']
      when FinancialProvider
        @shared_category_names_full |= ['Financial Information']
      end
    end
    @shared_category_names_full.reject { |sh| sh == "Trusts & Entities" }
  end
  
  def self.shares(owner, non_owner)
    return [] if non_owner.blank?
    owner.shares.where(contact: Contact.where("emailaddress ILIKE ?", non_owner.email))
  end
  
  def self.shares_by_contact(owner, contact)
    return [] if contact.blank?
    owner.shares.where(contact: contact)
  end
  
  def self.shared_group_names(owner, non_owner = nil, category = nil, contact = nil)
    all_shares = 
      if contact.present?
        shares_by_contact(owner, contact).select(&:shareable_type).select { |sh| Object.const_defined?(sh.shareable_type) }.map(&:shareable).delete_if { |x| x.is_a? Category}.compact
      else
        shares(owner, non_owner).select(&:shareable_type).select { |sh| Object.const_defined?(sh.shareable_type) }.map(&:shareable).delete_if { |x| x.is_a? Category}.compact
      end
    groups = Hash.new
    group_hash_initialize(groups)
    all_shares.each do |shareable|
      if category && shareable.category != Category.fetch(category.downcase)
        next
      end
      case shareable
      when Will
        groups.merge!("Will - POA" => (groups["Will - POA"] + [CardDocument.will(shareable.id).id]).uniq)
      when PowerOfAttorneyContact
        groups.merge!("Will - POA" => (groups["Will - POA"] + [CardDocument.power_of_attorney(shareable.id).id]).uniq)
      when Tax
        tax_year = TaxYearInfo.find_by(id: shareable.tax_year_id)
        next unless tax_year.present?
        groups.merge!("Tax" => (groups["Tax"] + [tax_year.year.to_s]).uniq)
      when FinalWish
        final_wish_info = FinalWishInfo.find_by(id: shareable.final_wish_info_id)
        next unless final_wish_info.present?
        groups.merge!("FinalWish" => (groups["FinalWish"] + [final_wish_info.group]).uniq)
      when Vendor
        groups.merge!("Vendor" => (groups["Vendor"] + [shareable.id]).uniq)
      when FinancialProvider
        groups.merge!("FinancialProvider" => (groups["FinancialProvider"] + [shareable.id]).uniq)
      else
        next
      end
    end
    groups
  end
  
  private
  
  def self.group_hash_initialize(groups)
    groups["Will - POA"] ||= []
    groups["Tax"] ||= []
    groups["FinalWish"] ||= []
    groups["Vendor"] ||= []
    groups["FinancialProvider"] ||= []
  end
end