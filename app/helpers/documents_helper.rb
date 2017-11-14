module DocumentsHelper
  @@add_new_document_title = "Add Document"
  @@empty_document_group = ["Select...", "0"]
  @@contact_category = "Contact"
  
  def document_shares(document)
    owner = document.user
    document_shares = (document.shares.flatten + subcategory_shares(document) + category_shares(document)).uniq(&:contact_id)
    document_shares.reject { |d_sh| d_sh.contact_id.zero? }
  end
  
  def subcategory_shares(document)
    owner = document.user
    return [] if owner.nil?
    shares = 
      if document.vendor_id.present? && document.vendor_id.positive?
        document.vendor.share_with_contacts
        owner.shares.where(shareable: document.vendor).includes(:contact).to_a
      elsif document.financial_information_id.present? && document.financial_information_id.positive?
        document.financial_provider.share_with_contacts
        owner.shares.where(shareable: document.financial_provider).includes(:contact).to_a
      elsif document.card_document_id.present? && document.card_document_id.positive?
        card_id = document.card_document.card_id
        card_type = document.card_document.object_type
        owner.shares.where(shareable_type: card_type, shareable_id: card_id).includes(:contact).to_a
      elsif document.group.present?
        model = ModelService.model_by_name(document.group)
        if model == Tax
          tax_year_id = TaxYearInfo.for_user(owner).find_by(:year => document.group).try(:id)
          return [] if tax_year_id.nil?
          tax_ids = Tax.for_user(owner).select { |x| x.tax_year_id == tax_year_id }.map(&:id).flatten
          owner.shares.where(shareable_type: 'Tax', shareable_id: tax_ids).includes(:contact).to_a
        elsif model == FinalWish
          final_wish_info_id = FinalWishInfo.for_user(owner).find_by(:group => document.group).try(:id)
          return [] if final_wish_info_id.nil?
          final_wish_ids = FinalWish.for_user(owner).select { |x| x.final_wish_info_id == final_wish_info_id }.map(&:id).flatten
          owner.shares.where(shareable_type: 'FinalWish', shareable_id: final_wish_ids).includes(:contact).to_a
        else
          return [] unless model.present?
          owner.shares.where(shareable_type: model.name).includes(:contact, :shareable_type).to_a.select(&:shareable_type)
        end
      else
        []
      end
  end
  
  def category_shares(document)
    return [] if document.category.nil? || document.category.blank? || (document.category.eql? DocumentService.empty_value)
    category = Category.fetch(document.category.downcase)
    return [] unless category.present?
    all = document.user.shares.categories.includes(:shareable, :contact).to_a
    all.select{ |sh| sh.shareable == category }
  end

  def add_new_document?(title)
    title == @@add_new_document_title
  end
  
  def category?(card_names, category)
    card_names.flatten.first[:id] == category
  end

  def document_return_path(document)
    return session[:ret_url] || documents_path unless @shared_user.present?
    session[:ret_url] || dashboard_shared_view_path(@shared_user)
  end
  
  def secondary_tag(document)
    if document_name_tag(document)
      document_name_tag(document)
    elsif document_group(document)
      document_group(document)
    else
      nil
    end
  end
  
  def document_name_tag(document)
    name = 
      if document.vendor_id.present? && document.vendor_id.positive?
        Vendor.find(document.vendor_id).name
      elsif document.financial_information_id.present? && document.financial_information_id.positive?
        FinancialProvider.find(document.financial_information_id).name
      elsif document.card_document_id.present? && document.card_document_id.positive?
        CardDocument.find(document.card_document_id).name
      end
    name.try(:truncate, 30)
  end

  def document_group(document)
    if document.category == @@contact_category
      contact = Contact.find_by_id(document.group)
      contact && truncate_name(contact.name)
    else
      asset_group(document.group)
    end
  end

  def document_category(document)
    return unless document.is_a? Document
    return unless category_shared_full?(document.user, document.category)
    asset_group(document.category)
  end

  def empty_group_category
    'Document'
  end

  def asset_type(resource)
    case resource
      when Document
        'Document'
      when Category
        return 'Document Upload' if resource.name.eql? Rails.application.config.x.DocumentsCategory
        'Category'
      else
        "Card"
      end
  end
  
  def insurance_document_count(user, group, category)
    service = DocumentService.new(:category => category)
    names = service.get_card_names(user, current_user)
    vendor_ids = names.flatten.map { |x| x[:id].to_i }.reject(&:zero?)
    DocumentService.new(:category => category).get_all_insurance_category_documents_count(user, group, vendor_ids)
  end

  def document_count(user, group, category)
    Document.for_user(user).where(category: category, group: group).count
  end
  
  def document_card_insurance_count(user, category, group, id)
    DocumentService.new(:category => category).get_insurance_documents(user, group, id).count
  end
  
  def document_card_count(user, category, id)
    Document.for_user(user).where(:category => category, :card_document_id => id).count
  end
  
  def document_card_financial_count(user, category, id)
    documents = DocumentService.new(:category => category).get_financial_documents(user, id)
    return 0 unless documents
    documents.count
  end
  
  def exists?(document)
    return false if document.try(:url).nil?
    s3_object = S3Service.get_object_by_key(document.url)
    s3_object.exists?
  end

  def get_file_url(key)
    return unless key.present?
    s3_object = S3Service.get_object_by_key(key)
    s3_object.presigned_url(:get, expires_in: 2.minutes.to_i)
  end
  
  def get_avatar_url(key)
    S3Service.stable_presigned_url_for_today(key) if key.present?
  end

  def download_file_link(document_url)
    s3_object = S3Service.get_object_by_key(document_url)
    s3_object.presigned_url(:get,
      response_content_disposition: "attachment", expires_in: 2.minutes.to_i)
  end

  private
    def asset_group(asset)
      if !asset || @@empty_document_group.any? {|doc| asset.start_with? doc}
        nil
      else
        asset
      end
    end
    
    def truncate_name(name)
      return nil unless name
      name.split(' ').map { |x| x.truncate(15) }.join(' ')
    end
end
