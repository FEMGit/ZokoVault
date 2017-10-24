class ClioService
  def initialize(access_token: nil)
    @client = client(access_token: access_token)
  end

  def authorization_link(redirect_url:)
    @client.authorize_url(redirect_url)
  end
  
  def authorize_with_code(redirect_url:, code:)
    if @client.access_token.present?
      return @client.access_token if Time.now < Time.at(@client.access_token[:expires_at])
      return refresh_token!(refresh_token: @client.access_token[:refresh_token])
    end
    
    token = @client.authorize_with_code(redirect_url, code)
    @client.access_token = token_information(access_token: token["access_token"], refresh_token: token["refresh_token"],
      expires_in: token["expires_in"])
    @client.access_token
  end
  
  def refresh_token!(refresh_token:)
    params = {:client_id => ENV["CLIO_CLIENT_ID"],
              :client_secret => ENV["CLIO_CLIENT_SECRET"],
              :grant_type => "refresh_token",
              :refresh_token => refresh_token }
    uri = @client.base_uri("/oauth/token")
    req = Net::HTTP::Post.new(uri)
    req.set_form_data params
    new_token = @client.make_request(req, uri)
    @client.access_token = token_information(access_token: new_token["access_token"], refresh_token: refresh_token,
      expires_in: new_token["expires_in"])
    @client.access_token
  end
  
  def client(access_token: nil)
    @client ||= ClioClient::Session.new({client_id: ENV["CLIO_CLIENT_ID"],
      client_secret: ENV["CLIO_CLIENT_SECRET"], base_scope_url: ENV["CLIO_BASE_SCOPE_URL"]})
    if access_token
      @client.access_token = access_token
    end
    @client
  end
  
  private
  
  def expires_at(expires_in:)
    Time.now + expires_in.to_i.seconds
  end
  
  def token_information(access_token:, refresh_token:, expires_in:)
    {token: access_token, refresh_token: refresh_token,
      expires_at: expires_at(expires_in: expires_in)}
  end
end
