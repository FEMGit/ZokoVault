class FilepickerService
  def self.pick_avatar_policy(expires_in: 10.minutes)
    ts = (Time.current + expires_in).to_i
    { expiry: ts, call: ['pick','store','convert'], path: '/avatars/' }
  end

  def self.pick_document_policy(expires_in: 10.minutes)
    ts = (Time.current + expires_in).to_i
    { expiry: ts, call: ['pick','store','convert'], path: '/documents/' }
  end

  def self.encode(policy)
    Base64.urlsafe_encode64(policy.to_json)
  end

  def self.sign(encoded_policy, secret: Rails.application.secrets.filepicker_secret)
    OpenSSL::HMAC.hexdigest('SHA256', secret, encoded_policy)
  end

  def self.policy_hash_string(policy:)
    encoded = encode(policy)
    signed  = sign(encoded)
    "{ policy: '#{encoded}', signature: '#{signed}' }"
  end

  def self.fetch_policy(key)
    policy =
      case key
      when :avatar   then pick_avatar_policy
      when :document then pick_document_policy
      end
    return policy_hash_string(policy: policy) if policy
    raise ArgumentError, "unknown filestack policy key: #{key.inspect}"
  end
end
