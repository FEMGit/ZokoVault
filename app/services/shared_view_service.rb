class SharedViewService
  def self.shared_categories_full(shares)
    @shared_category_names_full = shared_category_names(shares)
    shares.select(&:shareable_type).map(&:shareable).each do |shareable|
      case shareable
      when Will, PowerOfAttorneyContact
        @shared_category_names_full |= [Rails.application.config.x.WillsPoaCategory]
      when Trust, Entity
        @shared_category_names_full |= [Rails.application.config.x.TrustsEntitiesCategory]
      when Health, PropertyAndCasualty, LifeAndDisability
        @shared_category_names_full |= [Rails.application.config.x.InsuranceCategory]
      when Tax
        @shared_category_names_full |= [Rails.application.config.x.TaxCategory]
      when FinalWish
        @shared_category_names_full |= [Rails.application.config.x.FinalWishesCategory]
      when FinancialProvider
        @shared_category_names_full |= [Rails.application.config.x.FinancialInformationCategory]
      when OnlineAccount
        @shared_category_names_full |= [Rails.application.config.x.OnlineAccountCategory]
      end
    end
    @shared_category_names_full
  end
  
  def self.shared_category_names(shares)
    shares.select(&:shareable_type).select { |sh| sh.shareable.is_a? Category }.map(&:shareable).map(&:name)
  end
  
  def self.category_shares(shares)
    shares.select(&:shareable_type).select { |sh| sh.shareable.is_a? Category }
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
        shares_by_contact(owner, contact).select(&:shareable_type).map(&:shareable).delete_if { |x| x.is_a? Category}.compact
      else
        shares(owner, non_owner).select(&:shareable_type).map(&:shareable).delete_if { |x| x.is_a? Category}.compact
      end
    groups = Hash.new
    group_hash_initialize(groups)
    all_shares.each do |shareable|
      if category && shareable.category != Category.fetch(category.downcase)
        next
      end
      case shareable
      when Will
        next if CardDocument.will(shareable.id).blank?
        groups.merge!("Will - POA" => (groups["Will - POA"] + [CardDocument.will(shareable.id).id]).uniq)
      when PowerOfAttorneyContact
        next if CardDocument.power_of_attorney(shareable.id).blank?
        groups.merge!("Will - POA" => (groups["Will - POA"] + [CardDocument.power_of_attorney(shareable.id).id]).uniq)
      when Trust
        next if CardDocument.trust(shareable.id).blank?
        groups.merge!("Trusts & Entities" => (groups["Trusts & Entities"] + [CardDocument.trust(shareable.id).id]).uniq)
      when Entity
        next if CardDocument.entity(shareable.id).blank?
        groups.merge!("Trusts & Entities" => (groups["Trusts & Entities"] + [CardDocument.entity(shareable.id).id]).uniq)
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
      when OnlineAccount
        groups.merge!("Online Accounts" => (groups["OnlineAccount"] + [shareable.id]).uniq)
      else
        next
      end
    end
    groups
  end
  
  private
  
  def self.group_hash_initialize(groups)
    groups["Will - POA"] ||= []
    groups["Trusts & Entities"] ||= []
    groups["Tax"] ||= []
    groups["FinalWish"] ||= []
    groups["Vendor"] ||= []
    groups["FinancialProvider"] ||= []
    groups["OnlineAccount"] ||= []
  end
end