require 'forwardable'

class PasswordService
  
  class << self
    def for_per_user_key(puk)
      new(puk.plaintext)
    end
  end
  
  def initialize(secret_key)
    @crypto = SymmetricEncryption.new(secret_key)
  end
  
  def encrypt_password(password)
    crypto.encrypt(password)
  end
  
  def decrypt_password(password)
    crypto.decrypt(password)
  end
    
  private
  attr_reader :crypto
    
end

class SymmetricEncryption
  extend Forwardable
  def_delegators :@simple_box, :encrypt, :decrypt
  
  def initialize(key)
    @simple_box = RbNaCl::SimpleBox.from_secret_key(key)
  end
end
