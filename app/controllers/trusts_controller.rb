class TrustsController < WtlBaseController
  def set_group
    @group = "Trust"
  end
  
  def set_ret_url
    session[:ret_url] = "/trusts/details/#{current_wtl}"
  end
  
  private
  
  def current_wtl
    params[:trust]
  end
end
