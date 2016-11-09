class S3Service
  def self.get_object_by_key(document_key)
    Aws::S3::Object.new(Rails.application.secrets.aws_bucket_name, document_key, region: Rails.application.secrets.aws_region, credentials: credentials)
  end
  
  def self.delete_from_storage(document_key, options = {})
    client = Aws::S3::Client.new(region: Rails.application.secrets.aws_region, credentials: credentials)
    client.delete_object(options.merge(:bucket => Rails.application.secrets.aws_bucket_name, :key => document_key))
  end

  def self.credentials
    Aws::Credentials.new(Rails.application.secrets.aws_access_key_id, Rails.application.secrets.aws_access_secret_key)
  end
end
