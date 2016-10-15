module DocumentsHelper
  @@add_new_document_title = "Add Document"
  def add_new_document?(title)
    title == @@add_new_document_title
  end
  
  def document_return_path(document)
    session[:ret_url] || document_path(document)
  end
end
