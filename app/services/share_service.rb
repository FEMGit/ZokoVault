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
  
  def self.shared_documents_by_contact(resource_owner, contact)
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
      SharedViewService.shares_by_contact(owner, contact).select(&:shareable_type)
                                                         .select { |sh| sh.shareable.is_a? Category }.map(&:shareable).map(&:name)
    elsif user.present?
      SharedViewService.shares(owner, user).select(&:shareable_type)
                                           .select { |sh| sh.shareable.is_a? Category }.map(&:shareable).map(&:name)
    end
  end
  
  def self.shared_resource(shares, resource_type)
    shares.select(&:shareable_type).map(&:shareable).select { |resource| resource.is_a? resource_type }
  end
end
