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
end
