module DocumentsHelper
  @@add_new_document_title = "Add Document"
  @@empty_document_group = ["Select...", "0"]
  def add_new_document?(title)
    title == @@add_new_document_title
  end
  
  def document_return_path(document)
    session[:ret_url] || document_path(document)
  end
  
  def document_group(document)
    asset_group(document.group) || asset_group(document.category) || 'Document'
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
