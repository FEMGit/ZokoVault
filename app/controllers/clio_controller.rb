class ClioController < AuthenticatedController
  before_action :set_clio_service
  
  def authorization
    redirect_to @clio_service.authorization_link(redirect_url: redirect_url)
  end
  
  def index
    session[:clio_access_token] = @clio_service.authorize_with_code(redirect_url: redirect_url, code: params[:code])
  end
  
  private
  
  def set_clio_service
    @clio_service = ClioService.new(access_token: session[:clio_access_token])
  end
  
  def redirect_url
   uri = URI.parse(request.url)
   uri.path = clios_path
   uri.query = nil
   uri.to_s
  end
  
  def redirect_uri
    return clios_url
  end
end
