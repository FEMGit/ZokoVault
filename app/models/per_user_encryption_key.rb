require 'zoku/aws/kms'

class PerUserEncryptionKey < ActiveRecord::Base
  belongs_to :user, inverse_of: :per_user_encryption_keys
  
  has_many :online_accounts, inverse_of: :per_user_encryption_key
  
  def self.kms_client
    @kms_client ||= Zoku::AWS::KMS.client
  end
  
  def self.fetch_for(user)
    user.per_user_encryption_keys.order(id: :desc).first || setup_new_key(user)
  end
  
  def self.setup_new_key(user)
    resp = kms_client.generate_data_key_without_plaintext(
      key_id: Zoku::AWS::KMS.key_alias,
      key_spec: "AES_256",
      encryption_context: { "UserId" => "#{user.id}" }
    )
    user.per_user_encryption_keys.create(
      ciphertext: resp.ciphertext_blob,
      aws_key_id: resp.key_id
    )
  end
  
  def plaintext
    self.class.kms_client.decrypt(
      ciphertext_blob: ciphertext,
      encryption_context: { "UserId" => "#{user_id}" }
    ).plaintext
  end
end
