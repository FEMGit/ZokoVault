class FilepickerService
  def self.pick_store_convert_read_policy(expires_in: 10.minutes)
    ts = (Time.current + expires_in).to_i
    { expiry: ts, call: ['pick', 'store', 'convert', 'read'] }
  end

  def self.encode(policy)
    Base64.urlsafe_encode64(policy.to_json)
  end

  def self.sign(encoded_policy, secret: Rails.application.secrets.filepicker_secret)
    OpenSSL::HMAC.hexdigest('SHA256', secret, encoded_policy)
  end

  def self.policy_hash_string(policy: self.pick_store_convert_read_policy)
    encoded = encode(policy)
    signed  = sign(encoded)
    "{ policy: '#{encoded}', signature: '#{signed}' }"
  end
end
