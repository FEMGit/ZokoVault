class SharedWillsController < SharedViewControllerBase
  before_action :set_documents
  
  def index
    if @category_shared
      @wills = Will.for_user(shared_user)
    else
      shareables = @shares.map(&:shareable)
      @wills = shareables.select { |resource| resource.is_a? Will }
      @group_documents = shareables.select { |resource| resource.is_a?(Document) && resource.group == "Will" }
    end
    @wills.each { |x| authorize x }
    session[:ret_url] = shared_wills_path
  end
  
  private
  
  def set_documents
    @group = "Will"
    @category = Rails.application.config.x.WtlCategory
    @group_documents = DocumentService.new(:category => @category).get_group_documents(shared_user, @group)
  end
  
  def set_category_shared
    if @shared_category_names.include? Rails.application.config.x.WtlCategory
      @category_shared = true
    end
  end
end