class WillsController < WtlBaseController
  def set_group
    @group = "Will"
  end
  
  def set_ret_url
    session[:ret_url] = "/wills/details/#{current_wtl}"
  end
  
  private
  
  def current_wtl
    params[:will]
  end
end
