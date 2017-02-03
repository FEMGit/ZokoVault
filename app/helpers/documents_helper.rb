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
        Vendor.find(document.vendor_id).share_with_contacts
        owner.shares.select { |sh| (sh.shareable.is_a? Vendor) && sh.shareable_id == document.vendor_id }
      elsif document.financial_information_id.present? && document.financial_information_id.positive?
        FinancialProvider.find(document.financial_information_id).share_with_contacts
        owner.shares.select { |sh| (sh.shareable.is_a? FinancialProvider) && sh.shareable_id == document.financial_information_id }
      elsif document.group.present?
        model = ModelService.model_by_name(document.group)
        if model == Tax
          tax_year_id = TaxYearInfo.find_by(:year => document.group).id
          tax_ids = Tax.for_user(owner).select { |x| x.tax_year_id == tax_year_id }.map(&:id).flatten
          owner.shares.select { |sh| (sh.shareable.is_a? Tax) && (tax_ids.include? sh.shareable_id) }
        elsif model == FinalWish
          final_wish_info_id = FinalWishInfo.find_by(:group => document.group).id
          final_wish_ids = FinalWish.for_user(owner).select { |x| x.final_wish_info_id == final_wish_info_id }.map(&:id).flatten
          owner.shares.select { |sh| (sh.shareable.is_a? FinalWish) && (final_wish_ids.include? sh.shareable_id) }
        else
          return [] unless model.present?
          owner.shares.select { |sh| sh.shareable.is_a? model }
        end
      else
        []
      end
  end
  
  def category_shares(document)
    return [] if document.category.nil? || (document.category.eql? DocumentService.empty_value)
    category = Category.fetch(document.category.downcase)
    return [] unless category.present?
    document.user.shares.select { |sh| sh.shareable == category }
  end

  def add_new_document?(title)
    title == @@add_new_document_title
  end
  
  def category?(card_names, category)
    card_names.flatten.first[:id] == category
  end

  def document_return_path(document)
    return session[:ret_url] || documents_path unless @shared_user.present?
    session[:ret_url] || shared_view_dashboard_path(@shared_user)
  end
  
  def document_name_tag(document)
    if document.vendor_id.present? && document.vendor_id.positive?
      Vendor.find(document.vendor_id).name
    elsif document.financial_information_id.present? && document.financial_information_id.positive?
      FinancialProvider.find(document.financial_information_id).name
    end
  end

  def document_group(document)
    if document.category == @@contact_category
      contact = Contact.find_by_id(document.group)
      contact && contact.name
    else
      asset_group(document.group)
    end
  end

  def document_category(document)
    return unless document.is_a? Document
    asset_group(document.category)
  end

  def empty_group_category
    'Document'
  end

  def asset_type(resource)
    case resource
      when Document
        return 'Document'
      when Category
        return 'Category'
      else
        "Card"
      end
  end

  def document_count(user, group, category)
    Document.for_user(user).where(category: category, group: group).count
  end
  
  def document_card_insurance_count(user, category, group, id)
    DocumentService.new(:category => category).get_insurance_documents(user, group, id).count
  end
  
  def document_card_financial_count(user, category, id)
    documents = DocumentService.new(:category => category).get_financial_documents(user, id)
    return 0 unless documents
    documents.count
  end

  def previewed?(document)
    return false if document.try(:url).nil?
    s3_object = S3Service.get_object_by_key(document.url)
    Document.previewed?(s3_object.content_type)
  end

  def get_file_url(key)
    return unless key.present?
    s3_object = S3Service.get_object_by_key(key)
    s3_object.presigned_url(:get, expires_in: 2.minutes)
  end

  def download_file(document_url)
    s3_object = S3Service.get_object_by_key(document_url)
    s3_object.presigned_url(:get, response_content_disposition: "attachment", expires_in: 2.minutes)
  end

  private
    def asset_group(asset)
      if !asset || @@empty_document_group.any? {|doc| asset.start_with? doc}
        nil
      else
        asset
      end
    end
end
