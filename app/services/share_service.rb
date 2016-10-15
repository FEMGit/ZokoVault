class ShareService
  
  attr_accessor :contact_ids, :user_id
  
  def initialize(params)
    @user_id = params[:user_id]
    @contact_ids = params[:contact_ids]
  end
  
  def fill_document_share
    #remove empty values if is't inside
    if(@contact_ids)
      @contact_ids.reject!{|x| x.empty?}
      hash = Hash.new
      @contact_ids.each_with_index {|contact_id, index| hash.merge!({index => {"user_id" => @user_id, "contact_id" => contact_id}}) }
      hash
    else
      Hash.new
    end
  end
end
