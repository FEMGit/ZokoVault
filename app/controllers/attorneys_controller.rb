class AttorneysController < WtlBaseController
  def set_group
    @group = "Legal"
  end
  
  def set_ret_url
    session[:ret_url] = "/attorneys/details/#{current_wtl}"
  end
  
  private
  
  def current_wtl
    params[:attorney]
  end
end
