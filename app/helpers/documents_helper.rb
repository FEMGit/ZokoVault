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
    if(document.category == @@contact_category)
      if(contact = Contact.find_by_id(document.group))
        contact.name
      end
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
    if (document.category == @@contact_category)
      @@contact_category
    else
      asset_group(document.group) || asset_group(document.category) || empty_group_category
    end
  end
  
  def document_count(user, group)
    Document.for_user(user).where(group: group).count
  end
  
  def is_previewed?(document)
    data = open(document.url)
    extension = data.meta['content-type']
    is_previewed = Document.is_previewed?(extension)
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
