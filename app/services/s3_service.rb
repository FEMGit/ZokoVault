class S3Service
  def self.get_object_by_key(document_key)
    Aws::S3::Object.new(Rails.application.secrets.aws_bucket_name, document_key, region: Rails.application.secrets.aws_region, credentials: assume_role_credentials)
  end
  
  def self.delete_from_storage(document_key, options = {})
    client = Aws::S3::Client.new(region: Rails.application.secrets.aws_region, credentials: assume_role_credentials)
    client.delete_object(options.merge(:bucket => Rails.application.secrets.aws_bucket_name, :key => document_key))
  end
  
  def self.assume_role_credentials
    sts = Aws::STS::Client.new(region: Rails.application.secrets.aws_region, credentials: user_credentials)
    Aws::AssumeRoleCredentials.new(client: sts, role_arn: Rails.application.secrets.aws_access_role, region: Rails.application.secrets.aws_region, role_session_name: 'S3Access')
  end

  def self.user_credentials
    Aws::Credentials.new(Rails.application.secrets.aws_user_key_id, Rails.application.secrets.aws_user_secret_key)
  end
end
