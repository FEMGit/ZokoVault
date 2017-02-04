class ShareService
  
  attr_accessor :contact_ids, :user_id
  
  def initialize(params)
    @user_id = params[:user_id]
    @contact_ids = params[:contact_ids]
  end
  
  def fill_document_share
    # remove empty values if is't inside
    doc_shares = {}
    if @contact_ids
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
  
  def self.shared_documents(resource_owner, user)
    shareables = SharedViewService.shares(resource_owner, user).map(&:shareable)
    direct_document_share = shareables.select { |res| res.is_a? Document }
    
    shared_group_names = shared_groups(resource_owner, user)
    shared_category_names = shared_categories(resource_owner, user)
    
    group_docs = Document.for_user(resource_owner).select { |x| shared_group_names.include? x.group }
    vendor_docs = Document.for_user(resource_owner).select { |x| shared_group_names.include? x.vendor_id }
    financial_docs = Document.for_user(resource_owner).select { |x| shared_group_names.include? x.financial_information_id }
    category_docs = Document.for_user(resource_owner).select { |x| shared_category_names.include? x.category }
    (group_docs + direct_document_share + category_docs + vendor_docs + financial_docs).uniq
  end
  
  def self.shared_cards(owner, user)
    shareables = SharedViewService.shares(owner, user).map(&:shareable)
    shareables.reject { |res| (res.is_a? Document) || (res.is_a? Category) }
  end
  
  def self.shared_groups(owner, user)
    SharedViewService.shared_group_names(owner, user)
  end
  
  def self.shared_categories(owner, user)
    SharedViewService.shares(owner, user).map(&:shareable).select  { |res| res.is_a? Category }.map(&:name)
  end
end
