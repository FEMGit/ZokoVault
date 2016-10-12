class UpdateDocumentService
  
  attr_accessor :user, :contact, :ret_url
  
  def initialize(params)
    @user = params[:user]
    @contact = params[:contact]
    @return_page = params[:ret_url].to_s
  end
  
  def update_document
    document_id = document_id_from_url

    return if document_id.nil?

    document = Document.for_user(@user).find(document_id)
    document.shares << Share.new(document_id: document_id, contact_id: @contact, user_id: @user.id)
  end
  
  private 

  def document_id_from_url
    # if it's not document edit we just go out from here
    match_data = @return_page.match(%r{documents\/(\d+)\/edit})
    return if match_data.nil?

    match_data.captures.first
  end
end
