class UpdateDocumentService
  
  attr_accessor :user, :contact, :ret_url
  
  def initialize(params)
    @user = params[:user]
    @contact = params[:contact]
    @return_page = params[:ret_url]
  end
  
  def update_document
    if get_document_id_from_url
      document_id = get_document_id_from_url
      document = Document.for_user(@user).find(document_id)
      document.shares << Share.new(document_id: document_id, contact_id: @contact, user_id: @user.id)
    end
  end
  
  def get_document_id_from_url
    #if it's not document edit we just go out from here
    if @return_page =~ /documents\/(\d+)\/edit/
      @return_page.match(/documents\/(\d+)\/edit/).captures.first
    end
  end
end
