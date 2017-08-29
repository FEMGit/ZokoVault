require 'zoku/aws/iam'

class S3Service
  def self.get_object_by_key(document_key, bucket: nil)
    bucket ||= Rails.application.secrets.aws_bucket_name
    Aws::S3::Object.new(
      bucket,
      document_key,
      region: Zoku::AWS::IAM.region,
      credentials: Zoku::AWS::IAM.s3_role
    )
  end

  def self.delete_from_storage(document_key, **options)
    options[:bucket] ||= Rails.application.secrets.aws_bucket_name
    client = Aws::S3::Client.new(
      region: Zoku::AWS::IAM.region,
      credentials: Zoku::AWS::IAM.s3_role
    )
    client.delete_object(options.merge(key: document_key))
  end
end
