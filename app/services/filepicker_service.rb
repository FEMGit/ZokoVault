class FilepickerService
  def self.policy
    json_policy = { :expiry => (Time.now + 10*60).to_i, call: ['pick', 'store'] }.to_json
    Base64.urlsafe_encode64(json_policy) << '='
  end
  
  def self.signature(filepicker_policy)
    OpenSSL::HMAC.hexdigest('SHA256', secret, filepicker_policy)
  end
  
  private

  def self.secret
    Rails.application.secrets.filepicker_secret
  end
end