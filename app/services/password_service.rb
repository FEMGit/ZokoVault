require 'forwardable'

class PasswordService
  class << self
    def encrypt_password(password)
      crypto.encrypt(password)
    end
    
    def decrypt_password(password)
      crypto.decrypt(password)
    end
    
    private
    
    def crypto
      @crypto ||= SymmetricEncryption.new(format_secret_key)
    end
    
    def format_secret_key
      Base64.strict_decode64(Rails.application.secrets.online_accounts_secret_key)
    end
  end
end

class SymmetricEncryption
  extend Forwardable
  def_delegators :@simple_box, :encrypt, :decrypt
  
  def initialize(key)
    @simple_box = RbNaCl::SimpleBox.from_secret_key(key)
  end
end
