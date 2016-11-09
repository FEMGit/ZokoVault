class S3Service
  def self.get_object_by_key(document_key)
    creds = Aws::Credentials.new(Rails.application.secrets.aws_access_key_id, Rails.application.secrets.aws_access_secret_key)
    s3object = Aws::S3::Object.new(Rails.application.secrets.aws_bucket_name, document_key, region: Rails.application.secrets.aws_region, credentials: creds)
  end
end