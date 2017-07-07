class ShareService
  attr_accessor :contact_ids, :user_id

  def initialize(params)
    @user_id = params[:user_id]
    @contact_ids = params[:contact_ids]
  end

  def fill_document_share
    # remove empty values if is't inside
    doc_shares = {}
    if @contact_ids.present?
      @contact_ids.reject!(&:empty?)
      @contact_ids.each_with_index do |contact_id, index|
        doc_shares[index] = { "user_id" => @user_id, "contact_id" => contact_id }
      end
    end

    doc_shares
  end

  def clear_shares(document)
    if document.shares.present?
      document.shares.clear
    end
  end

  def self.get_all_cards(owner, contact)
    return [] unless (owner.primary_shared_with_by_contact? contact)
    resource =
      FinancialProvider.for_user(owner) +
      Will.for_user(owner) +
      PowerOfAttorneyContact.for_user(owner) +
      Entity.for_user(owner) +
      Trust.for_user(owner) +
      Vendor.for_user(owner) +
      Tax.for_user(owner) +
      FinalWish.for_user(owner)
  end

  def self.shared_documents_by_contact(resource_owner, contact)
    return Document.for_user(resource_owner) if (resource_owner.primary_shared_with_by_contact? contact)
    shareables = SharedViewService.shares_by_contact(resource_owner, contact).select(&:shareable_type).map(&:shareable)
    direct_document_share = shareables.select { |res| res.is_a? Document }

    shared_group_names = shared_groups(resource_owner, nil, contact)
    shared_category_names = shared_categories(resource_owner, nil, contact)
    all_documents_shared(resource_owner, shared_group_names, shared_category_names, direct_document_share)
  end

  def self.shared_documents(resource_owner, user)
    shareables = SharedViewService.shares(resource_owner, user).select(&:shareable_type).map(&:shareable)
    direct_document_share = shareables.select { |res| res.is_a? Document }

    shared_group_names = shared_groups(resource_owner, user)
    shared_category_names = shared_categories(resource_owner, user)
    all_documents_shared(resource_owner, shared_group_names, shared_category_names, direct_document_share)
  end

  def self.all_documents_shared(resource_owner, shared_group_names, shared_category_names, direct_document_share)
    group_docs = Document.for_user(resource_owner).select { |x| (shared_group_names["Tax"].include? x.group) ||
                                                                (shared_group_names["FinalWish"].include? x.group) }
    vendor_docs = Document.for_user(resource_owner).select { |x| (shared_group_names["Vendor"].include? x.vendor_id) }
    financial_docs = Document.for_user(resource_owner).select { |x| (shared_group_names["FinancialProvider"].include? x.financial_information_id) }
    card_document_docs = Document.for_user(resource_owner).select { |x| (shared_group_names["Will - POA"].include? x.card_document_id) ||
                                                                        (shared_group_names["Trusts & Entities"].include? x.card_document_id) }
    category_docs = Document.for_user(resource_owner).select { |x| shared_category_names.include? x.category }
    (group_docs + direct_document_share + category_docs + vendor_docs + financial_docs + card_document_docs).uniq
  end

  def self.shared_cards(owner, user = nil, contact = nil)
    if (contact.present? && (owner.primary_shared_with_by_contact? contact))
      return get_all_cards(owner, contact)
    end
    shareables =
      if contact.present?
        SharedViewService.shares_by_contact(owner, contact).select(&:shareable_type).map(&:shareable)
      elsif user.present?
        SharedViewService.shares(owner, user).select(&:shareable_type).map(&:shareable)
      end
    shareables.compact.reject { |res| (res.is_a? Document) || (res.is_a? Category) }
  end

  def self.shared_groups(owner, user = nil, contact = nil)
    if contact.present?
      SharedViewService.shared_group_names(owner, nil, nil, contact)
    elsif user.present?
      SharedViewService.shared_group_names(owner, user)
    end
  end

  def self.shared_categories(owner, user = nil, contact = nil)
    if contact.present?
      return Rails.application.config.x.ShareCategories.dup if (owner.primary_shared_with_by_contact? contact)
      SharedViewService.shares_by_contact(owner, contact).select(&:shareable_type)
                                                         .select { |sh| sh.shareable.is_a? Category }.map(&:shareable).map(&:name)
    elsif user.present?
      return Rails.application.config.x.ShareCategories.dup if user.primary_shared_with?(owner)
      SharedViewService.shares(owner, user).select(&:shareable_type)
                                           .select { |sh| sh.shareable.is_a? Category }.map(&:shareable).map(&:name)
    end
  end

  def self.shared_resource(shares, resource_type)
    shares.select(&:shareable_type).map(&:shareable).select { |resource| resource.is_a? resource_type }
  end
  
  def self.category_contacts_shared_with(owner, category_name)
    category_id = Category.fetch(category_name.downcase).try(:id)
    return [] unless category_id.present?
    owner.shares.select { |sh| (sh.shareable_type.eql? 'Category') && (sh.shareable_id.eql? category_id) }.map(&:contact_id)
  end
  
  def self.subcategory_contacts_shared_with(owner, category_name, subcategory)
    category = Category.fetch(category_name.downcase)
    return [] unless category.present?
    category_shares = category_contacts_shared_with(owner, category_name)
    return category_shares if subcategory.eql? DocumentService.empty_value
    shareable_types = CategoryShareableTypes::SHAREABLE_TYPE[category.name]
    
    if category.name.eql? Rails.application.config.x.FinancialInformationCategory
      category_shares += resources_shared(owner, shareable_types, Array.wrap(subcategory.to_i)).map(&:contact_id).uniq
    elsif [Rails.application.config.x.WillsPoaCategory, Rails.application.config.x.TrustsEntitiesCategory].include? category.name
      card_document = CardDocument.find_by(id: subcategory)
      return category_shares unless card_document.present?
      object_type = card_document.object_type
      card_id = card_document.card_id
      category_shares += resources_shared(owner, shareable_types, Array.wrap(card_id), object_type).map(&:contact_id).uniq
    elsif category.name.eql? Rails.application.config.x.InsuranceCategory
      category_shares += resources_shared(owner, shareable_types, Array.wrap(subcategory.to_i)).map(&:contact_id).uniq
    elsif category.name.eql? Rails.application.config.x.TaxCategory
      category_shares += resources_shared(owner, shareable_types, TaxesService.tax_ids_by_year(subcategory, owner)).map(&:contact_id).uniq
    elsif category.name.eql? Rails.application.config.x.FinalWishesCategory
      category_shares += resources_shared(owner, shareable_types, FinalWishService.final_wish_ids_by_group(subcategory, owner)).map(&:contact_id).uniq
    end
  end
  
  private
  
  def self.resource_shared?(share, shareable_type_name, ids, object_type = nil)
    return false unless ids.present?
    if object_type.blank?
      (share.shareable_type.eql? shareable_type_name) && (ids.include? share.shareable_id)
    else
      (share.shareable_type.eql? shareable_type_name) && (ids.include? share.shareable_id) &&
      (object_type.eql? shareable_type_name)
    end
  end
  
  def self.resources_shared(owner, shareable_types, ids, object_type = nil)
    resources = []
    shareable_types.each do |shareable_type_name|
      resources += owner.shares.select { |sh| resource_shared?(sh, shareable_type_name, ids, object_type) }
    end
    return resources
  end
end
