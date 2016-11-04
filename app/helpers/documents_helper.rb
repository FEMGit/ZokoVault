module DocumentsHelper
  @@add_new_document_title = "Add Document"
  @@empty_document_group = ["Select...", "0"]
  @@contact_category = "Contact"

  def add_new_document?(title)
    title == @@add_new_document_title
  end

  def document_return_path(document)
    session[:ret_url] || document_path(document)
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

  def previewed?(document)
    s3_object = S3Service.get_object_by_key(document.url)
    Document.previewed?(s3_object.content_type)
  end

  def get_file_url(key)
    s3_object = S3Service.get_object_by_key(key)
    s3_object.presigned_url(:get)
  end

  def download_file(document_url)
    s3_object = S3Service.get_object_by_key(document_url)
    s3_object.presigned_url(:get, response_content_disposition: "attachment")
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
