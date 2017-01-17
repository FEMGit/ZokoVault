module DocumentsHelper
  @@add_new_document_title = "Add Document"
  @@empty_document_group = ["Select...", "0"]
  @@contact_category = "Contact"

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
    asset_group(document.category)
  end

  def empty_group_category
    'Document'
  end

  def asset_type(document)
    if document.category == @@contact_category
      @@contact_category
    else
      asset_group(document.group) || asset_group(document.category) || empty_group_category
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
